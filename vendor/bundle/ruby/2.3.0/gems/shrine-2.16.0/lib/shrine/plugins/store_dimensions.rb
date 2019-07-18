# frozen_string_literal: true

class Shrine
  module Plugins
    # Documentation lives in [doc/plugins/store_dimensions.md] on GitHub.
    #
    # [doc/plugins/store_dimensions.md]: https://github.com/shrinerb/shrine/blob/master/doc/plugins/store_dimensions.md
    module StoreDimensions
      def self.configure(uploader, opts = {})
        uploader.opts[:dimensions_analyzer] = opts.fetch(:analyzer, uploader.opts.fetch(:dimensions_analyzer, :fastimage))
      end

      module ClassMethods
        # Determines the dimensions of the IO object by calling the specified
        # analyzer.
        def extract_dimensions(io)
          analyzer = opts[:dimensions_analyzer]
          analyzer = dimensions_analyzer(analyzer) if analyzer.is_a?(Symbol)
          args = [io, dimensions_analyzers].take(analyzer.arity.abs)

          dimensions = analyzer.call(*args)
          io.rewind

          dimensions
        end

        # Returns a hash of built-in dimensions analyzers, where keys are
        # analyzer names and values are `#call`-able objects which accepts the
        # IO object.
        def dimensions_analyzers
          @dimensions_analyzers ||= DimensionsAnalyzer::SUPPORTED_TOOLS.inject({}) do |hash, tool|
            hash.merge!(tool => dimensions_analyzer(tool))
          end
        end

        # Returns callable dimensions analyzer object.
        def dimensions_analyzer(name)
          DimensionsAnalyzer.new(name).method(:call)
        end
      end

      module InstanceMethods
        # We update the metadata with "width" and "height".
        def extract_metadata(io, context = {})
          width, height = extract_dimensions(io)

          super.merge!("width" => width, "height" => height)
        end

        private

        # Extracts dimensions using the specified analyzer.
        def extract_dimensions(io)
          self.class.extract_dimensions(io)
        end

        # Returns a hash of built-in dimensions analyzers.
        def dimensions_analyzers
          self.class.dimensions_analyzers
        end
      end

      module FileMethods
        def width
          Integer(metadata["width"]) if metadata["width"]
        end

        def height
          Integer(metadata["height"]) if metadata["height"]
        end

        def dimensions
          [width, height] if width || height
        end
      end

      class DimensionsAnalyzer
        SUPPORTED_TOOLS = [:fastimage, :mini_magick, :ruby_vips]

        def initialize(tool)
          raise Error, "unknown dimensions analyzer #{tool.inspect}, supported analyzers are: #{SUPPORTED_TOOLS.join(",")}" unless SUPPORTED_TOOLS.include?(tool)

          @tool = tool
        end

        def call(io)
          dimensions = send(:"extract_with_#{@tool}", io)
          io.rewind
          dimensions
        end

        private

        def extract_with_fastimage(io)
          require "fastimage"
          FastImage.size(io)
        end

        def extract_with_mini_magick(io)
          require "mini_magick"
          Shrine.with_file(io) { |file| MiniMagick::Image.new(file.path).dimensions }
        rescue MiniMagick::Error
        end

        def extract_with_ruby_vips(io)
          require "vips"
          Shrine.with_file(io) { |file| Vips::Image.new_from_file(file.path).size }
        rescue Vips::Error
        end
      end
    end

    register_plugin(:store_dimensions, StoreDimensions)
  end
end
