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
  end
end
