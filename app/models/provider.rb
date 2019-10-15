class Provider < ApplicationRecord
  has_many :courses
  has_many :application_choices, through: :courses
end
