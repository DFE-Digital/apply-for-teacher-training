class Course < ApplicationRecord
  belongs_to :provider
  has_many :application_choices
end
