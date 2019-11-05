class Provider < ApplicationRecord
  has_many :courses
  has_many :course_options, through: :courses
  has_many :application_choices, through: :course_options
end
