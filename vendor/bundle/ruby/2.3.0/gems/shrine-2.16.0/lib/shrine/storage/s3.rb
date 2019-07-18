# frozen_string_literal: true

require "shrine"
begin
  require "aws-sdk-s3"
  if Gem::Version.new(Aws::S3::GEM_VERSION) < Gem::Version.new("1.2.0")
    raise "Shrine::Storage::S3 requires aws-sdk-s3 version 1.2.0 or above"
  end
rescue LoadError => exception
  begin
    require "aws-sdk"
    Shrine.deprecation("Using aws-sdk 2.x is deprecated and support for it will be removed in Shrine 3, use the new aws-sdk-s3 gem instead.")
    Aws.eager_autoload!(services: ["S3"])
  rescue LoadError
    raise exception
  end
end

require "down/chunked_io"
require "content_disposition"

require "uri"
require "cgi"
require "tempfile"

class Shrine
  module Storage
    class S3
      attr_reader :client, :bucket, :prefix, :host, :upload_options, :signer, :public

      # Initializes a storage for uploading to S3. All options are forwarded to
      # [`Aws::S3::Client#initialize`], except the following:
      #
      # :bucket
      # : (Required). Name of the S3 bucket.
      #
      # :client
      # : By default an `Aws::S3::Client` instance is created internally from
      #   additional options, but you can use this option to provide your own
      #   client. This can be an `Aws::S3::Client` or an
      #   `Aws::S3::Encryption::Client` object.
      #
      # :prefix
      # : "Directory" inside the bucket to store files into.
      #
      # :upload_options
      # : Additional options that will be used for uploading files, they will
      #   be passed to [`Aws::S3::Object#put`], [`Aws::S3::Object#copy_from`]
      #   and [`Aws::S3::Bucket#presigned_post`].
      #
      # :multipart_threshold
      # : If the input file is larger than the specified size, a parallelized
      #   multipart will be used for the upload/copy. Defaults to
      #   `{upload: 15*1024*1024, copy: 100*1024*1024}` (15MB for upload
      #   requests, 100MB for copy requests).
      #
      # In addition to specifying the `:bucket`, you'll also need to provide
      # AWS credentials. The most common way is to provide them directly via
      # `:access_key_id`, `:secret_access_key`, and `:region` options. But you
      # can also use any other way of authentication specified in the [AWS SDK
      # documentation][configuring AWS SDK].
      #
      # [`Aws::S3::Object#put`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#put-instance_method
      # [`Aws::S3::Object#copy_from`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#copy_from-instance_method
      # [`Aws::S3::Bucket#presigned_post`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#presigned_post-instance_method
      # [`Aws::S3::Client#initialize`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method
      # [configuring AWS SDK]: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html
      def initialize(bucket:, client: nil, prefix: nil, host: nil, upload_options: {}, multipart_threshold: {}, signer: nil, public: nil, **s3_options)
        raise ArgumentError, "the :bucket option is nil" unless bucket

        Shrine.deprecation("The :host option to Shrine::Storage::S3#initialize is deprecated and will be removed in Shrine 3. Pass :host to S3#url instead, you can also use default_url_options plugin.") if host

        if multipart_threshold.is_a?(Integer)
          Shrine.deprecation("Accepting the :multipart_threshold S3 option as an integer is deprecated, use a hash with :upload and :copy keys instead, e.g. {upload: 15*1024*1024, copy: 150*1024*1024}")
          multipart_threshold = { upload: multipart_threshold }
        end
        multipart_threshold = { upload: 15*1024*1024, copy: 100*1024*1024 }.merge(multipart_threshold)

        @client = client || Aws::S3::Client.new(**s3_options)
        @bucket = Aws::S3::Bucket.new(name: bucket, client: @client)
        @prefix = prefix
        @host = host
        @upload_options = upload_options
        @multipart_threshold = multipart_threshold
        @signer = signer
        @public = public
      end

      # Returns an `Aws::S3::Resource` object.
      def s3
        Shrine.deprecation("Shrine::Storage::S3#s3 that returns an Aws::S3::Resource is deprecated, use Shrine::Storage::S3#client which returns an Aws::S3::Client object.")
        Aws::S3::Resource.new(client: @client)
      end

      # If the file is an UploadedFile from S3, issues a COPY command, otherwise
      # uploads the file. For files larger than `:multipart_threshold` a
      # multipart upload/copy will be used for better performance and more
      # resilient uploads.
      #
      # It assigns the correct "Content-Type" taken from the MIME type, because
      # by default S3 sets everything to "application/octet-stream".
      def upload(io, id, shrine_metadata: {}, **upload_options)
        content_type, filename = shrine_metadata.values_at("mime_type", "filename")

        options = {}
        options[:content_type] = content_type if content_type
        options[:content_disposition] = ContentDisposition.inline(filename) if filename
        options[:acl] = "public-read" if public

        options.merge!(@upload_options)
        options.merge!(upload_options)

        options[:content_disposition] = encode_content_disposition(options[:content_disposition]) if options[:content_disposition]

        if copyable?(io)
          copy(io, id, **options)
        else
          bytes_uploaded = put(io, id, **options)
          shrine_metadata["size"] ||= bytes_uploaded
        end
      end

      # Returns a `Down::ChunkedIO` object that downloads S3 object content
      # on-demand. By default, read content will be cached onto disk so that
      # it can be rewinded, but if you don't need that you can pass
      # `rewindable: false`.
      #
      # Any additional options are forwarded to [`Aws::S3::Object#get`].
      #
      # [`Aws::S3::Object#get`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#get-instance_method
      def open(id, rewindable: true, **options)
        object = object(id)

        load_data(object, **options)

        Down::ChunkedIO.new(
          chunks:     object.enum_for(:get, **options),
          rewindable: rewindable,
          size:       object.content_length,
          data:       { object: object },
        )
      end

      # Returns true file exists on S3.
      def exists?(id)
        object(id).exists?
      end

      # Returns the presigned URL to the file.
      #
      # :host
      # :  This option replaces the host part of the returned URL, and is
      #    typically useful for setting CDN hosts (e.g.
      #    `http://abc123.cloudfront.net`)
      #
      # :download
      # :  If set to `true`, creates a "forced download" link, which means that
      #    the browser will never display the file and always ask the user to
      #    download it.
      #
      # All other options are forwarded to [`Aws::S3::Object#presigned_url`] or
      # [`Aws::S3::Object#public_url`].
      #
      # [`Aws::S3::Object#presigned_url`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#presigned_url-instance_method
      # [`Aws::S3::Object#public_url`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#public_url-instance_method
      def url(id, download: nil, public: self.public, host: self.host, **options)
        options[:response_content_disposition] ||= "attachment" if download
        options[:response_content_disposition] = encode_content_disposition(options[:response_content_disposition]) if options[:response_content_disposition]

        if public || signer
          url = object(id).public_url(**options)
        else
          url = object(id).presigned_url(:get, **options)
        end

        if host
          uri = URI.parse(url)
          uri.path = uri.path.match(/^\/#{bucket.name}/).post_match unless uri.host.include?(bucket.name)
          url = URI.join(host, uri.request_uri[1..-1]).to_s
        end

        if signer
          url = signer.call(url, **options)
        end

        url
      end

      # Returns URL, params, headers, and verb for direct uploads.
      #
      #     s3.presign("key") #=>
      #     # {
      #     #   url: "https://my-bucket.s3.amazonaws.com/...",
      #     #   fields: { ... },  # blank for PUT presigns
      #     #   headers: { ... }, # blank for POST presigns
      #     #   method: "post",
      #     # }
      #
      # By default it calls [`Aws::S3::Object#presigned_post`] which generates
      # data for a POST request, but you can also specify `method: :put` for
      # PUT uploads which calls [`Aws::S3::Object#presigned_url`].
      #
      #     s3.presign("key", method: :post) # for POST upload (default)
      #     s3.presign("key", method: :put)  # for PUT upload
      #
      # Any additional options are forwarded to the underlying AWS SDK method.
      #
      # [`Aws::S3::Object#presigned_post`]: http://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#presigned_post-instance_method
      # [`Aws::S3::Object#presigned_url`]: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#presigned_url-instance_method
      def presign(id, method: :post, **presign_options)
        options = {}
        options[:acl] = "public-read" if public

        options.merge!(@upload_options)
        options.merge!(presign_options)

        options[:content_disposition] = encode_content_disposition(options[:content_disposition]) if options[:content_disposition]

        if method == :post
          presigned_post = object(id).presigned_post(options)

          Struct.new(:method, :url, :fields).new(method, presigned_post.url, presigned_post.fields)
        else
          url = object(id).presigned_url(method, options)

          # When any of these options are specified, the corresponding request
          # headers must be included in the upload request.
          headers = {}
          headers["Content-Length"]      = options[:content_length]      if options[:content_length]
          headers["Content-Type"]        = options[:content_type]        if options[:content_type]
          headers["Content-Disposition"] = options[:content_disposition] if options[:content_disposition]
          headers["Content-Encoding"]    = options[:content_encoding]    if options[:content_encoding]
          headers["Content-Language"]    = options[:content_language]    if options[:content_language]
          headers["Content-MD5"]         = options[:content_md5]         if options[:content_md5]

          { method: method, url: url, headers: headers }
        end
      end

      # Deletes the file from the storage.
      def delete(id)
        object(id).delete
      end

      # If block is given, deletes all objects from the storage for which the
      # block evaluates to true. Otherwise deletes all objects from the storage.
      #
      #     s3.clear!
      #     # or
      #     s3.clear! { |object| object.last_modified < Time.now - 7*24*60*60 }
      def clear!(&block)
        objects_to_delete = Enumerator.new do |yielder|
          bucket.objects(prefix: prefix).each do |object|
            yielder << object if block.nil? || block.call(object)
          end
        end

        delete_objects(objects_to_delete)
      end

      # Returns an `Aws::S3::Object` for the given id.
      def object(id)
        bucket.object([*prefix, id].join("/"))
      end

      # Catches the deprecated `#download` and `#stream` methods.
      def method_missing(name, *args, &block)
        case name
        when :stream   then deprecated_stream(*args, &block)
        when :download then deprecated_download(*args, &block)
        else
          super
        end
      end

      private

      # Copies an existing S3 object to a new location. Uses multipart copy for
      # large files.
      def copy(io, id, **options)
        # pass :content_length on multipart copy to avoid an additional HEAD request
        options = { multipart_copy: true, content_length: io.size }.merge!(options) if io.size && io.size >= @multipart_threshold[:copy]
        object(id).copy_from(io.storage.object(io.id), **options)
      end

      # Uploads the file to S3. Uses multipart upload for large files.
      def put(io, id, **options)
        bytes_uploaded = nil

        if (path = extract_path(io))
          # use `upload_file` for files because it can do multipart upload
          options = { multipart_threshold: @multipart_threshold[:upload] }.merge!(options)
          object(id).upload_file(path, **options)
          bytes_uploaded = File.size(path)
        else
          io.to_io if io.is_a?(UploadedFile) # open if not already opened

          if io.respond_to?(:size) && io.size && (io.size <= @multipart_threshold[:upload] || !object(id).respond_to?(:upload_stream))
            object(id).put(body: io, **options)
            bytes_uploaded = io.size
          elsif object(id).respond_to?(:upload_stream)
            # `upload_stream` uses multipart upload
            object(id).upload_stream(tempfile: true, **options) do |write_stream|
              bytes_uploaded = IO.copy_stream(io, write_stream)
            end
          else
            Shrine.deprecation "Uploading a file of unknown size with aws-sdk-s3 older than 1.14 is deprecated and will be removed in Shrine 3. Update to aws-sdk-s3 1.14 or higher."

            Tempfile.create("shrine-s3", binmode: true) do |file|
              bytes_uploaded = IO.copy_stream(io, file.path)
              object(id).upload_file(file.path, **options)
            end
          end
        end

        bytes_uploaded
      end

      # Aws::S3::Object#load doesn't support passing options to #head_object,
      # so we call #head_object ourselves and assign the response data
      def load_data(object, **options)
        # filter out #get_object options that are not valid #head_object options
        options = options.select do |key, value|
          client.config.api.operation(:head_object).input.shape.member?(key)
        end

        response = client.head_object(
          bucket: bucket.name,
          key: object.key,
          **options
        )

        object.instance_variable_set(:@data, response.data)
      end

      def extract_path(io)
        if io.respond_to?(:path)
          io.path
        elsif io.is_a?(UploadedFile) && defined?(Storage::FileSystem) && io.storage.is_a?(Storage::FileSystem)
          io.storage.path(io.id).to_s
        end
      end

      # The file is copyable if it's on S3 and on the same Amazon account.
      def copyable?(io)
        io.is_a?(UploadedFile) &&
        io.storage.is_a?(Storage::S3) &&
        io.storage.client.config.access_key_id == client.config.access_key_id
      end

      # Deletes all objects in fewest requests possible (S3 only allows 1000
      # objects to be deleted at once).
      def delete_objects(objects)
        objects.each_slice(1000) do |objects_batch|
          delete_params = { objects: objects_batch.map { |object| { key: object.key } } }
          bucket.delete_objects(delete: delete_params)
        end
      end

      # Upload requests will fail if filename has non-ASCII characters, because
      # of how S3 generates signatures, so we URI-encode them. Most browsers
      # should automatically URI-decode filenames when downloading.
      def encode_content_disposition(content_disposition)
        content_disposition.sub(/(?<=filename=").+(?=")/) do |filename|
          if filename =~ /[^[:ascii:]]/
            Shrine.deprecation("Shrine::Storage::S3 will not escape characters in the filename for Content-Disposition header in Shrine 3. Use the content_disposition gem, for example `ContentDisposition.format(disposition: 'inline', filename: '...')`.")
            CGI.escape(filename).gsub("+", " ")
          else
            filename
          end
        end
      end

      def deprecated_stream(id)
        Shrine.deprecation("Shrine::Storage::S3#stream is deprecated over calling #each_chunk on S3#open.")
        object = object(id)
        object.get { |chunk| yield chunk, object.content_length }
      end

      def deprecated_download(id, **options)
        Shrine.deprecation("Shrine::Storage::S3#download is deprecated over S3#open.")

        tempfile = Tempfile.new(["shrine-s3", File.extname(id)], binmode: true)
        data = object(id).get(response_target: tempfile, **options)
        tempfile.content_type = data.content_type
        tempfile.tap(&:open)
      rescue
        tempfile.close! if tempfile
        raise
      end

      # Tempfile with #content_type accessor which represents downloaded files.
      class Tempfile < ::Tempfile
        attr_accessor :content_type
      end
    end
  end
end
