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
  end
end
