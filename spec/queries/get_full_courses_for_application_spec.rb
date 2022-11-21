require 'rails_helper'

RSpec.describe GetFullCoursesForApplication do
  let(:course) { create(:course, :open_on_apply) }
  let(:course_option) { create(:course_option, course: course, vacancy_status: 'no_vacancies') }
  let(:application_choice) { create(:application_choice, course_option: course_option) }
  let(:application_form) { create(:application_form, application_choices: [application_choice]) }

  describe '#call' do
    context 'when an application form has a full choice' do
      it 'returns the course' do
        service = described_class.new(application_form:).call

        expect(service).to eq [course]
      end
    end
  end
end
