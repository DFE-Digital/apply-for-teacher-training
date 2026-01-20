require 'rails_helper'

RSpec.describe CandidateInterface::PreviousApplicationReviewComponent, type: :component do
  context 'when a course choice is provided' do
    let(:application_form) { create(:application_form, recruitment_cycle_year: RecruitmentCycleTimetable.current_year, submitted_at: 3.days.ago) }
    let!(:application_choice) { create(:application_choice, :withdrawn, application_form: application_form) }

    it 'renders the details of the choice' do
      result = render_inline(described_class.new(application_choice:))

      expect(result).to have_content('Application withdrawn')
      expect(result).to have_content(application_choice.course.name_and_code)
      expect(result).to have_content(application_choice.course.qualifications_to_s)
      expect(result).to have_content(application_choice.course.study_mode.humanize.to_s)
      expect(result).to have_content(application_choice.personal_statement)
    end
  end
end
