class Provider < ApplicationRecord
  has_many :training_locations
  has_many :courses
end
