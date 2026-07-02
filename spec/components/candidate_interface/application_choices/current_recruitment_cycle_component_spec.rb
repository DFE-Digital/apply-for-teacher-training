require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::CurrentRecruitmentCycleComponent do
  let(:application_form) { create(:application_form, recruitment_cycle_year: 2026) }

  describe '#academic_year_title' do
    subject(:academic_year_title) { described_class.new(application_form:).academic_year_title }

    it 'returns the title for the component within the academic year' do
      expect(academic_year_title).to eq('Courses for the 2026 to 2027 academic year')
    end
  end
end
