class DataMigration < ApplicationRecord
  audited

  validates :service_name, uniqueness: { scope: :timestamp }
end
