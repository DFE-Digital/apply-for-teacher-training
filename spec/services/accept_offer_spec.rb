require 'rails_helper'

RSpec.describe AcceptOffer do
  it 'sets the accepted_at date for the application_choice' do
    application_choice = create(:application_choice, status: :offer)

    Timecop.freeze do
      expect {
        AcceptOffer.new(application_choice: application_choice).save!
      }.to change { application_choice.accepted_at }.to(Time.zone.now)
    end
  end

  describe 'emails' do
    around { |example| perform_enqueued_jobs(&example) }

    it 'sends a notification email to the provider' do
      application_choice = create(:application_choice, status: :offer)
      provider_user = create :provider_user, providers: [application_choice.provider]

      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(ActionMailer::Base.deliveries.first.to).to eq [provider_user.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/has accepted your offer/)
    end

    it 'sends a confirmation email to the candidate' do
      application_choice = create(:application_choice, status: :offer)

      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You’ve accepted/)
    end
  end
end
