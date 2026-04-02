require 'rails_helper'

RSpec.describe EmailQuery do
  describe '.call' do
    subject(:call) { described_class.call(params:) }

    let(:params) { {} }

    context 'when no params are given' do
      let(:emails) { create_list(:email, 10) }
      let(:older_email) { create(:email, created_at: 11.days.ago) }

      before do
        emails
        older_email
      end

      it 'returns all emails' do
        all_emails = Email.where(id: emails.pluck(:id) << older_email.id)
        expect(call).to match_array(all_emails)
      end
    end

    context 'when given created since params' do
      let(:params) { { created_since: 10.days.ago } }
      let(:emails) { create_list(:email, 10) }
      let(:older_email) { create(:email, created_at: 12.days.ago) }

      before do
        emails
        older_email
      end

      it 'returns only emails created within the last 10 days' do
        recent_emails = Email.where(id: emails.pluck(:id))
        expect(call).to match_array(recent_emails)
      end
    end

    context 'when given to params' do
      let(:email_bob) { create(:email, to: 'bob@example.com') }
      let(:email_jane) { create(:email, to: 'jane@example.com') }
      let(:params) { { to: 'bob@example.com' } }

      before do
        email_bob
        email_jane
      end

      it 'returns only emails sent to the given email address' do
        expect(call).to contain_exactly(email_bob)
      end
    end

    context 'when given subject params' do
      let(:subject_1_email) { create(:email, subject: 'Subject 1') }
      let(:subject_2_email) { create(:email, subject: 'Subject 2') }
      let(:params) { { subject: 'Subject 1' } }

      before do
        subject_1_email
        subject_2_email
      end

      it 'returns only emails containing the given subject' do
        expect(call).to contain_exactly(subject_1_email)
      end
    end

    context 'when given notify reference params' do
      let(:notify_1_email) { create(:email, notify_reference: 'ABC123') }
      let(:notify_2_email) { create(:email, notify_reference: 'XYZ7809') }
      let(:params) { { notify_reference: 'ABC123' } }

      before do
        notify_1_email
        notify_2_email
      end

      it 'returns only emails with the given notify reference' do
        expect(call).to contain_exactly(notify_1_email)
      end
    end

    context 'when given body params' do
      let(:body_1_email) { create(:email, body: 'A piece of cake') }
      let(:body_2_email) { create(:email, body: 'Easy as pie') }
      let(:params) { { email_body: 'cake' } }

      before do
        body_1_email
        body_2_email
      end

      it 'returns only emails containing the given email body' do
        expect(call).to contain_exactly(body_1_email)
      end
    end

    context 'when given delivery status params' do
      let(:delivered_email) { create(:email, delivery_status: 'delivered') }
      let(:pending_email) { create(:email, delivery_status: 'pending') }
      let(:skipped_email) { create(:email, delivery_status: 'skipped') }
      let(:params) { { delivery_status: %w[delivered pending] } }

      before do
        delivered_email
        pending_email
        skipped_email
      end

      it 'returns only emails containing the given email body' do
        expect(call).to contain_exactly(delivered_email, pending_email)
      end
    end

    context 'when given mailer in params' do
      let(:provider_email) { create(:email, mailer: 'provider_mailer') }
      let(:candidate_email) { create(:email, mailer: 'candidate_mailer') }
      let(:referee_mailer) { create(:email, mailer: 'referee_mailer') }
      let(:params) { { mailer: %w[provider_mailer candidate_mailer] } }

      before do
        provider_email
        candidate_email
        referee_mailer
      end

      it 'returns only emails for the given mailer' do
        expect(call).to contain_exactly(provider_email, candidate_email)
      end
    end

    context 'when given mailer template in params' do
      let(:application_submitted_email) { create(:email, mail_template: 'application_submitted') }
      let(:new_offer_made_email) { create(:email, mail_template: 'new_offer_made') }
      let(:offer_accepted_email) { create(:email, mail_template: 'offer_accepted') }
      let(:params) { { mail_template: %w[application_submitted new_offer_made] } }

      before do
        application_submitted_email
        new_offer_made_email
        offer_accepted_email
      end

      it 'returns only emails for the given mailer' do
        expect(call).to contain_exactly(application_submitted_email, new_offer_made_email)
      end
    end

    context 'when given application form id params' do
      let(:application_form_1) { create(:application_form) }
      let(:application_form_2) { create(:application_form) }
      let(:application_form_1_application_submitted_email) do
        create(
          :email,
          mail_template: 'application_submitted',
          application_form: application_form_1,
        )
      end
      let(:application_form_1_new_offer_made_email) do
        create(
          :email,
          mail_template: 'new_offer_made',
          application_form: application_form_1,
        )
      end
      let(:application_form_2_email) do
        create(
          :email,
          mail_template: 'offer_accepted',
          application_form: application_form_2,
        )
      end
      let(:params) { { application_form_id: application_form_1.id } }

      before do
        application_form_1_application_submitted_email
        application_form_1_new_offer_made_email
        application_form_2_email
      end

      it 'returns only emails for the given application form' do
        expect(call).to contain_exactly(
          application_form_1_application_submitted_email,
          application_form_1_new_offer_made_email,
        )
      end
    end

    context 'when given a provider code param' do
      let(:provider) { create(:provider, code: 'ZZZ') }
      let(:provider_user_1) { create(:provider_user, providers: [provider]) }
      let(:provider_user_2) { create(:provider_user, providers: [provider]) }
      let(:provider_user_3) { create(:provider_user) }
      let(:user_1_email) { create(:email, to: provider_user_1.email_address) }
      let(:user_2_email) { create(:email, to: provider_user_2.email_address) }
      let(:user_3_email) { create(:email, to: provider_user_3.email_address) }
      let(:params) { { provider_code: 'ZZZ' } }

      before do
        user_1_email
        user_2_email
        user_3_email
      end

      it 'returns only emails for users associated with the given provider' do
        expect(call).to contain_exactly(user_1_email, user_2_email)
      end

      context 'when the provider code given does not match a provider' do
        let(:params) { { provider_code: 'XXX' } }

        it 'returns no email records' do
          expect(call).to eq(Email.none)
        end
      end
    end
  end
end
