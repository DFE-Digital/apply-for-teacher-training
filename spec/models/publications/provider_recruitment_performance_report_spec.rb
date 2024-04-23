require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReport do
  describe 'associations' do
    it { is_expected.to belong_to :provider }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
  end
end
