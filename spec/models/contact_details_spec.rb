require 'rails_helper'

describe ContactDetails, type: :model do
  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to validate_length_of(:phone_number).is_at_most(35) }

  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to validate_length_of(:email_address).is_at_most(250) }

  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_length_of(:address).is_at_most(250) }
end
