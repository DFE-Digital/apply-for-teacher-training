require 'rails_helper'

RSpec.describe SupportInterface::AddCourseChoiceAfterSubmission do
  describe '#call' do
    it 'creates a new application choice for an application form with the preferred course option and sends it to the provider' do
      application_form = create(:application_form)
      course_option = create(:course_option)

      called = described_class.new(application_form:, course_option:).call

      appended_application_choice = application_form.reload.application_choices.order(:created_at, :id).last

      expect(called).to eq(appended_application_choice)
      expect(called.application_form).to eq(application_form)
      expect(called.course_option).to eq(course_option)
      expect(called.status).to eq('awaiting_provider_decision')
      expect(called.sent_to_provider_at).not_to be_blank
      expect(called.provider_ids).not_to be_empty
      expect(called.current_recruitment_cycle_year).to be_present
    end
  end
end
