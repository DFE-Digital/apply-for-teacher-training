require 'rails_helper'

describe PersonalDetails, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :first_name }
  it { is_expected.to validate_presence_of :last_name }
  it { is_expected.to validate_presence_of :date_of_birth }

  it { is_expected.to validate_presence_of(:phone_number).on(:update) }
  it { is_expected.to validate_presence_of(:email_address).on(:update) }
  it { is_expected.to validate_presence_of(:address).on(:update) }
end
