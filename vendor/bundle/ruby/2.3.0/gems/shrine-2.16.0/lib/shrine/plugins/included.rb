# frozen_string_literal: true

class Shrine
  module Plugins
    # Documentation lives in [doc/plugins/included.md] on GitHub.
    #
    # [doc/plugins/included.md]: https://github.com/shrinerb/shrine/blob/master/doc/plugins/included.md
    module Included
      def self.configure(uploader, &block)
        uploader.opts[:included_block] = block
      end

      module AttachmentMethods
        def included(model)
          super
          model.instance_exec(@name, &shrine_class.opts[:included_block])
        end
      end
    end

    register_plugin(:included, Included)
  end
end
