require 'rails_helper'

RSpec.describe ReinstateReference, :sidekiq do
  describe '#call' do
    it 'requests a reference' do
      course_option = create(:course_option, course: create(:course, provider: create(:provider)))
      application_choices = [create(:application_choice, :accepted, course_option:)]
      application_form = create(:application_form, application_choices:)
      reference = create(:reference, :cancelled, application_form: application_form)
      described_class.new(reference, audit_comment: 'somezendesk ticket').call

      expect(reference.reload).to be_feedback_requested
      expect(reference.cancelled_at).to be_nil
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array(reference.email_address)
    end
  end
end
