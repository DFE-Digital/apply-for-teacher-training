require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::ReviewDegreeGradeInterruptionPolicy do
  let(:application_form) { create(:application_form, :completed, :with_degree) }
  let(:candidate) { application_form.candidate }
  let(:degree) { application_form.application_qualifications.find_by(level: 'degree') }

  let(:provider) { create(:provider, name: 'Gorse SCITT', code: '1N1') }
  let(:course) do
    create(:course, :open, code: '238T', provider:, level: 'secondary', degree_grade: 'two_one')
  end
  let(:course_option) { create(:course_option, course: course) }

  let(:application_choice) do
    create(:application_choice, :unsubmitted, application_form: application_form, course_option: course_option)
  end

  permissions :show? do
    context 'when the grade is below that required for the course' do
      before do
        degree.update(grade: 'Third-class honours', qualification_type: 'Bachelor of Arts', predicted_grade: false, qualification_type_hesa_code: '051')
        application_form.application_qualifications.reload
      end

      it 'permits the user to view the page' do
        expect(described_class).to permit(candidate, application_choice)
      end
    end

    context 'when the grade is equal to or above that required for the course' do
      before do
        degree.update(grade: 'First-class honours', qualification_type: 'Bachelor of Arts', predicted_grade: false, qualification_type_hesa_code: '051')
        application_form.application_qualifications.reload
      end

      it 'does not the user to view the page' do
        expect(described_class).not_to permit(candidate, application_choice)
      end
    end
  end
end
