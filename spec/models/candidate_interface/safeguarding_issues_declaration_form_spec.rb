require 'rails_helper'

RSpec.describe CandidateInterface::SafeguardingIssuesDeclarationForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:share_safeguarding_issues) }

    valid_text = Faker::Lorem.sentence(word_count: 400)
    invalid_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(valid_text).for(:safeguarding_issues) }
    it { is_expected.not_to allow_value(invalid_text).for(:safeguarding_issues) }
  end
end
