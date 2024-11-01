require 'rails_helper'

RSpec.describe SendApplyToAnotherCourseWhenInactiveEmailToCandidatesBatchWorker, :sidekiq do
  describe '#perform' do
    let(:application_forms) { create_list(:completed_application_form, 2) }

    subject(:perform) { described_class.new.perform(application_forms.pluck(:id)) }

    before do
      create(:application_choice, :inactive, application_form: application_forms.first)
      create(:application_choice, :inactive, application_form: application_forms.second)
      perform
    end

    it 'sends apply to another course email' do
      expect(email_template_sent?).to be_truthy
      expect(application_forms.first.chasers_sent.apply_to_another_course_after_30_working_days.count).to eq(1)
      expect(application_forms.second.chasers_sent.apply_to_another_course_after_30_working_days.count).to eq(1)
      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end

    it 'does not send the email again' do
      expect {
        perform
      }.to not_change(ActionMailer::Base.deliveries, :count)
     .and not_change(application_forms.first.chasers_sent.apply_to_another_course_after_30_working_days, :count)
     .and not_change(application_forms.second.chasers_sent.apply_to_another_course_after_30_working_days, :count)
    end
  end

  def email_template_sent?
    template = 'apply_to_another_course_after_30_working_days'
    ActionMailer::Base.deliveries.find { |e| e.rails_mail_template == template }
  end
end
