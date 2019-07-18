# frozen_string_literal: true

class Shrine
  module Plugins
    # Documentation lives in [doc/plugins/processing.md] on GitHub.
    #
    # [doc/plugins/processing.md]: https://github.com/shrinerb/shrine/blob/master/doc/plugins/processing.md
    module Processing
      def self.configure(uploader)
        uploader.opts[:processing] ||= {}
      end

      module ClassMethods
        def process(action, &block)
          opts[:processing][action] ||= []
          opts[:processing][action] << block
        end
      end

      module InstanceMethods
        def process(io, context = {})
          pipeline = opts[:processing][context[:action]] || []

          result = pipeline.inject(io) do |input, processing|
            instance_exec(input, context, &processing) || input
          end

          result unless result == io
        end
      end
    end

    register_plugin(:processing, Processing)
  end
end
