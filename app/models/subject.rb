class Subject < ApplicationRecord
  validates :code, uniqueness: true
end
