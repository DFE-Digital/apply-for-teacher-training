require 'rails_helper'

RSpec.describe SendApplyAgainCallToAction do
  describe '#perform' do
    it 'sends a call to action email to the candidate with the unsuccessful application' do
      successful_application_form = FactoryBot.create(:completed_application_form)
      unsuccessful_application_form = FactoryBot.create(:completed_application_form)
      FactoryBot.create(
        :application_choice,
        status: :offer,
        application_form: successful_application_form,
      )
      FactoryBot.create(
        :application_choice,
        status: :rejected,
        application_form: unsuccessful_application_form,
      )

      expect { described_class.new.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [unsuccessful_application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You can still apply for teacher training/)
    end

    it 'does not send a call to action email to a candidate that already received the email' do
      unsuccessful_application_form = FactoryBot.create(:completed_application_form)
      FactoryBot.create(
        :application_choice,
        status: :rejected,
        application_form: unsuccessful_application_form,
      )
      Email.create!(
        application_form_id: unsuccessful_application_form.id,
        to: unsuccessful_application_form.candidate.email_address,
        subject: 'you can still apply',
        body: 'some text',
        mailer: 'candidate_mailer',
        mail_template: 'apply_again_call_to_action',
      )

      expect { described_class.new.perform }.not_to(change { ActionMailer::Base.deliveries.count })
    end

    it 'does not send a call to action email to a candidate that already started apply again' do
      unsuccessful_application_form = FactoryBot.create(:completed_application_form)
      FactoryBot.create(
        :application_choice,
        status: :rejected,
        application_form: unsuccessful_application_form,
      )
      DuplicateApplication.new(unsuccessful_application_form).duplicate

      expect { described_class.new.perform }.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end
end
