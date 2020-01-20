require 'rails_helper'

RSpec.shared_examples "a callback that doesn't change the feedback status of a reference" do
  it 'returns not updated' do
    process_notify_callback = ProcessNotifyCallback.call(notify_reference: notify_reference, status: status)

    expect(process_notify_callback).to eq(:not_updated)
  end

  it 'does not update the feedback status of the reference' do
    ProcessNotifyCallback.call(notify_reference: notify_reference, status: status)

    expect(reference.reload.feedback_status).to eq('feedback_requested')
  end
end

RSpec.describe ProcessNotifyCallback do
  let(:reference) do
    application_form = create(:application_form)
    create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
  end

  context 'when expected Notify reference is provided' do
    let(:notify_reference) { "test-reference_request-#{reference.id}" }

    context 'with permanent-failure status' do
      let(:status) { 'permanent-failure' }

      it 'returns updated' do
        process_notify_callback = ProcessNotifyCallback.call(notify_reference: notify_reference, status: status)

        expect(process_notify_callback).to eq(:updated)
      end

      it 'updates the feedback status of the reference to email bounced' do
        ProcessNotifyCallback.call(notify_reference: notify_reference, status: status)

        expect(reference.reload.feedback_status).to eq('email_bounced')
      end

      it 'returns not found if reference cannot be found' do
        allow(ApplicationReference).to receive(:exists?).with(reference.id.to_s).and_return(false)

        process_notify_callback = ProcessNotifyCallback.call(notify_reference: notify_reference, status: status)

        expect(process_notify_callback).to eq(:not_found)
      end
    end

    context 'with another status' do
      let(:status) { 'temporary-failure' }

      it_behaves_like "a callback that doesn't change the feedback status of a reference"
    end
  end

  context 'when unexpected Notify reference is provided' do
    let(:status) { 'permanent-failure' }

    context 'with environment not matching current environment' do
      let(:environment) { 'qa' }
      let(:notify_reference) { "#{environment}-reference_request-#{reference.id}" }

      it_behaves_like "a callback that doesn't change the feedback status of a reference"
    end

    context 'with email type not reference request' do
      let(:email_type) { 'survey_email' }
      let(:notify_reference) { "test-#{email_type}-#{reference.id}" }

      it_behaves_like "a callback that doesn't change the feedback status of a reference"
    end
  end
end
