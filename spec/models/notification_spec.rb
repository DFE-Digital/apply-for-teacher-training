require 'rails_helper'

RSpec.describe Notification do
  it { is_expected.to belong_to(:notified) }

  it {
    expect(described_class.new).to define_enum_for(:notification_type)
    .with_values(pool_opt_in: 'pool_opt_in')
    .backed_by_column_of_type(:string)
  }
end
