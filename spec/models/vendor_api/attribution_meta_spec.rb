require 'rails_helper'

RSpec.describe VendorAPI::AttributionMeta do
  subject { described_class.new({}) }

  it { is_expected.to validate_presence_of :full_name }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :user_id }

  it { is_expected.to validate_length_of(:full_name).is_at_most(120) }
  it { is_expected.to validate_length_of(:email).is_at_most(100) }
  it { is_expected.to validate_length_of(:user_id).is_at_most(100) }
end
