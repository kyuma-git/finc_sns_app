# frozen_string_literal: true

class Shrine
  module Plugins
    # Documentation lives in [doc/plugins/refresh_metadata.md] on GitHub.
    #
    # [doc/plugins/refresh_metadata.md]: https://github.com/shrinerb/shrine/blob/master/doc/plugins/refresh_metadata.md
    module RefreshMetadata
      module FileMethods
        def refresh_metadata!(context = {})
          refreshed_metadata =
            if @io
              uploader.extract_metadata(self, context)
            else
              open { uploader.extract_metadata(self, context) }
            end

          @data = @data.merge("metadata" => metadata.merge(refreshed_metadata))
        end
      end
    end

    register_plugin(:refresh_metadata, RefreshMetadata)
  end
end
