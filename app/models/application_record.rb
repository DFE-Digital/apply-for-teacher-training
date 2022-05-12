class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include DfE::Analytics::Entities
end
