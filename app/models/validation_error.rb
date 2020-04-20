class ValidationError < ApplicationRecord
  validates :form_object, presence: true

  belongs_to :user, polymorphic: true
end
