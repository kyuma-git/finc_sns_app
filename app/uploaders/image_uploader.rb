require "image_processing/mini_magick"

class ImageUploader < Shrine
  plugin :processing # allows hooking into promoting
  plugin :versions   # enable Shrine to handle a hash of files
  plugin :delete_raw # delete processed files after uploading

  process(:store) do |io, context|
    versions = { original: io } # retain original

    io.download do |original|
      pipeline = ImageProcessing::MiniMagick.source(original)

      versions[:medium] = pipeline.resize_to_limit!(200, 200)
      versions[:small]  = pipeline.resize_to_limit!(150, 150)
    end

    versions # return the hash of processed files
  end
end