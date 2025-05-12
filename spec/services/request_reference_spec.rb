require 'rails_helper'

RSpec.describe RequestReference do
  let(:application_form) { create(:application_form, recruitment_cycle_year: 2023) }

  describe '#send_request' do
    context 'when one of the references has incomplete email' do
      it 'is invalid' do
        reference = create(:reference, email_address: nil, application_form: application_form)
        request_reference = described_class.new(reference: reference)
        expect(request_reference.send_request).to be_falsey
        expect(request_reference.errors[:reference]).to include(
          I18n.t('errors.messages.incomplete_references'),
        )
      end
    end

    context 'when one of the references has incomplete relationship' do
      it 'is invalid' do
        reference = create(:reference, relationship: nil, application_form: application_form)
        request_reference = described_class.new(reference: reference)
        expect(request_reference.send_request).to be_falsey
        expect(request_reference.errors[:reference]).to include(
          I18n.t('errors.messages.incomplete_references'),
        )
      end
    end

    context 'when reference is auto-approved in sandbox' do
      it 'sets confidential to true' do
        allow(HostingEnvironment).to receive(:workflow_testing?).and_return(true)
        reference = create(:reference, email_address: 'refbot1@example.com', application_form: application_form, confidential: nil)
        request_reference = described_class.new(reference:)

        request_reference.send_request

        expect(reference.reload.confidential).to be true
        expect(reference.feedback_status).to eq('feedback_provided')
        expect(reference.feedback).to eq('Automatically approved.')
      end
    end

    context 'when not in sandbox (production environment)' do
      it 'does not auto-approve the reference' do
        allow(HostingEnvironment).to receive(:workflow_testing?).and_return(false)

        reference = create(:reference, email_address: 'refbot1@example.com', application_form: application_form, confidential: nil)
        request_reference = described_class.new(reference: reference)

        request_reference.send_request

        expect(reference.reload.confidential).to be_nil
        expect(reference.feedback_status).not_to eq('feedback_provided')
      end
    end
  end
end
