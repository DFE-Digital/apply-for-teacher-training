require 'rails_helper'

RSpec.describe CandidateInterface::NewCourseChoiceNeededBannerComponent do
  describe '#render?' do
    let(:application_form) { create(:application_form) }

    context 'when a course is only available on ucas and the candidate is awaiting their references' do
      it 'renders the component' do
        create(:course, withdrawn: false, open_on_apply: false)
        create(:application_choice, application_form: application_form, status: 'awaiting_references')

        expect(described_class.new(application_form: application_form).render?).to be_truthy
      end
    end

    context 'when a course has been withdrawn and the candidate is awaiting their references' do
      it 'renders the component' do
        course = create(:course, withdrawn: true, open_on_apply: true)
        course_option = create(:course_option, course: course)
        create(:application_choice, application_form: application_form, course_option: course_option, status: 'awaiting_references')

        expect(described_class.new(application_form: application_form).render?).to be_truthy
      end
    end

    context 'when a course has been withdrawn and the candidates application is complete' do
      it 'does not render the componen' do
        course = create(:course, withdrawn: true, open_on_apply: true)
        course_option = create(:course_option, course: course)
        create(:application_choice, application_form: application_form, course_option: course_option, status: 'application_complete')

        expect(described_class.new(application_form: application_form).render?).to be_falsey
      end
    end

    context 'when a course has not been withdrawn' do
      it 'does not render the component' do
        course = create(:course, withdrawn: false, open_on_apply: true)
        course_option = create(:course_option, course: course)
        create(:application_choice, application_form: application_form, course_option: course_option, status: 'awaiting_references')

        expect(described_class.new(application_form: application_form).render?).to be_falsey
      end
    end

    context 'when a course choice has become full' do
      it 'renders the component' do
        course = create(:course, withdrawn: false, open_on_apply: true)
        course_option = build(:course_option, vacancy_status: 'no_vacancies', course: course)
        create(:application_choice, application_form: application_form, course_option: course_option, status: 'awaiting_references')

        expect(described_class.new(application_form: application_form).render?).to be_truthy
      end
    end

    context 'when a course choice still has vacancies' do
      it 'does not render the component' do
        course = create(:course, withdrawn: false, open_on_apply: true)
        course_option = build(:course_option, vacancy_status: 'vacancies', course: course)
        create(:application_choice, application_form: application_form, course_option: course_option, status: 'awaiting_references')

        expect(described_class.new(application_form: application_form).render?).to be_falsey
      end
    end
  end
end
