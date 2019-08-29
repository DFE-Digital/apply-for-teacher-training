require 'rails_helper'

RSpec.describe Candidate, type: :model do
  subject { FactoryBot.create(:candidate) }

  it { is_expected.to validate_presence_of :email_address }
  it { is_expected.to validate_length_of(:email_address).is_at_most(250) }
  it { is_expected.to validate_uniqueness_of :email_address }
end
