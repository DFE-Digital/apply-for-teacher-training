require 'rails_helper'

RSpec.shared_examples 'a callback that does not change the feedback status of a reference' do
  it 'does not update the feedback status of the reference' do
    process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

    process_notify_callback.call

    expect(reference.reload.feedback_status).to eq('feedback_requested')
  end
end

RSpec.describe ProcessNotifyCallback do
  around do |example|
    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
      example.run
    end
  end

  let(:reference) do
    application_form = create(:application_form)
    create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
  end
  let(:candidate) { create(:candidate, sign_up_email_bounced: false, hide_in_reporting: false) }

  context 'when expected Notify reference is provided with reference request' do
    let(:notify_reference) { "example_env-reference_request-#{reference.id}" }

    context 'with permanent-failure status' do
      let(:status) { 'permanent-failure' }

      it 'updates the feedback status of the reference to email bounced' do
        process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

        process_notify_callback.call

        expect(reference.reload.feedback_status).to eq('email_bounced')
      end

      it 'sets not found to true if reference cannot be found' do
        allow(ApplicationReference).to receive(:find).with(reference.id.to_s).and_raise(ActiveRecord::RecordNotFound)

        process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

        process_notify_callback.call

        expect(process_notify_callback).to be_not_found
      end
    end

    context 'with another status' do
      let(:status) { 'temporary-failure' }

      it_behaves_like 'a callback that does not change the feedback status of a reference'
    end
  end

  context 'when expected Notify reference is provided with sign up email' do
    let(:notify_reference) { "example_env-sign_up_email-#{candidate.id}" }

    context 'with permanent-failure status' do
      let(:status) { 'permanent-failure' }

      it 'updates sign up email bounced to true for candidate' do
        process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

        process_notify_callback.call

        expect(candidate.reload.sign_up_email_bounced).to be(true)
      end

      it 'updates hide in reporting to true for candidate' do
        process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

        process_notify_callback.call

        expect(candidate.reload.hide_in_reporting).to be(true)
      end

      it 'sets not found to true if candidate cannot be found' do
        allow(Candidate).to receive(:find).with(candidate.id.to_s).and_raise(ActiveRecord::RecordNotFound)

        process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

        process_notify_callback.call

        expect(process_notify_callback).to be_not_found
      end
    end
  end

  context 'when unexpected Notify reference is provided' do
    let(:status) { 'permanent-failure' }

    context 'with environment not matching current environment' do
      let(:environment) { 'qa' }
      let(:notify_reference) { "#{environment}-reference_request-#{reference.id}" }

      it_behaves_like 'a callback that does not change the feedback status of a reference'
    end

    context 'with email type not reference request or sign up email bounced' do
      let(:email_type) { 'example_email' }
      let(:notify_reference) { "example_env-#{email_type}-#{reference.id}" }

      it_behaves_like 'a callback that does not change the feedback status of a reference'

      it 'does not update sign up email bounced and hide in reporting to true for candidate' do
        notify_reference = "example_env-#{email_type}-#{candidate.id}"
        process_notify_callback = described_class.new(notify_reference: notify_reference, status: status)

        process_notify_callback.call

        expect(candidate.reload.sign_up_email_bounced).to be(false)
        expect(candidate.reload.hide_in_reporting).to be(false)
      end
    end
  end
end
