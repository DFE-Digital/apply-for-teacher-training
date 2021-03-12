require 'rails_helper'

RSpec.describe DataMigration, type: :model do
  it { is_expected.to validate_uniqueness_of(:service_name).scoped_to(:timestamp) }
end
