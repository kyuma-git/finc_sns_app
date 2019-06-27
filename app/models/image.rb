# frozen_string_literal: true

class Image < ApplicationRecord
  include ImageUploader[:image]
  belongs_to :post
end
