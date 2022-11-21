require 'rails_helper'

RSpec.describe GetCoursesNotYetOpenForApplication do
  let(:course) { create(:course, :open_on_apply, applications_open_from: 1.day.from_now) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_choice) { create(:application_choice, course_option: course_option) }
  let(:application_form) { create(:application_form, application_choices: [application_choice]) }

  describe '#call' do
    context 'when an application form has closed choices' do
      it 'returns the course' do
        service = described_class.new(application_form:).call

        expect(service).to eq [course]
      end
    end
  end
end
