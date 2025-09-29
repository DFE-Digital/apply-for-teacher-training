require 'rails_helper'

RSpec.describe CandidateInterface::PreferencesEmail do
  let(:preference) { create(:candidate_preference) }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

  describe '.call' do
    context 'when opt_in and first email has not sent' do
      before { allow(CandidateMailer).to receive(:pool_opt_in).and_return(mailer) }

      it 'calls CandidateMailer.pool_opt_in' do
        described_class.call(preference:)

        expect(CandidateMailer).to have_received(:pool_opt_in).with(
          preference.application_form,
        )
        expect(mailer).to have_received(:deliver_later)
      end
    end

    context 'when opt_in and first email has been sent' do
      let(:email) { create(:email, mail_template: 'pool_opt_in') }
      let(:preference) do
        create(
          :candidate_preference,
          application_form: email.application_form,
        )
      end

      before { allow(CandidateMailer).to receive(:pool_opt_in).and_return(mailer) }

      it 'calls CandidateMailer.pool_opt_in' do
        described_class.call(preference:)

        expect(CandidateMailer).not_to have_received(:pool_opt_in).with(
          preference.application_form,
        )
      end
    end

    context 'when opt_out' do
      let(:preference) { create(:candidate_preference, pool_status: 'opt_out') }

      before { allow(CandidateMailer).to receive(:pool_opt_in).and_return(mailer) }

      it 'calls CandidateMailer.pool_opt_in' do
        described_class.call(preference:)

        expect(CandidateMailer).not_to have_received(:pool_opt_in).with(
          preference.application_form,
        )
      end
    end
  end
end
