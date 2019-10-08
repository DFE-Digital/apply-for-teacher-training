require 'rails_helper'

RSpec.describe VendorApi::AttributionMeta do
  subject { VendorApi::AttributionMeta.new({}) }

  it { is_expected.to validate_presence_of :full_name }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :user_id }
end
