require 'rails_helper'

describe PersonalDetails, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_length_of(:title).is_at_most(4) }

  it { is_expected.to validate_presence_of :first_name }
  it { is_expected.to validate_presence_of :last_name }

  it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
  it { is_expected.to validate_length_of(:preferred_name).is_at_most(50) }
end
