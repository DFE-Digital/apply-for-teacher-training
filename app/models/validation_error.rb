class ValidationError < ApplicationRecord
  validates :form_object, presence: true
end
