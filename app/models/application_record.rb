class ApplicationRecord < ActiveRecord::Base
  include EntityEvents

  self.abstract_class = true
end
