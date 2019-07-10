require 'rails_helper'

describe PersonalDetails, type: :model do
  it { is_expected.to validate_presence_of :title }
end
