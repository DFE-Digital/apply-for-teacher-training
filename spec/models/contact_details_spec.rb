require 'rails_helper'

describe ContactDetails, type: :model do
  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to validate_presence_of(:address) }
end
