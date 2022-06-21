class Site < ApplicationRecord
  belongs_to :provider
  has_many :course_options
end
