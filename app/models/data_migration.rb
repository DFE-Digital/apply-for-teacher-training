class DataMigration < ApplicationRecord

  validates :service_name, uniqueness: { scope: :timestamp }
end
