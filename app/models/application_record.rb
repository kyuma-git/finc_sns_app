# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  IMAGE_MAX_LENGTH = 3
end
