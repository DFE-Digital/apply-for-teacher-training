require 'rails_helper'

RSpec.describe Publications::NationalRecruitmentPerformanceReport do
  describe 'associations' do
    it { is_expected.to have_one :recruitment_cycle_timetable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
  end
end
