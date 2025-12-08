require 'rails_helper'

RSpec.describe IsApplicationAnonymised do
  let(:application_form) { create(:completed_application_form) }
  let(:service) { described_class.new(application_form:).call }

  describe '#call' do
    context 'when the application has been deleted' do
      it 'returns true' do
        application_form.candidate.update!(email_address: "deleted-application-#{application_form.support_reference}@example.com")
        expect(service).to be true
      end
    end

    context 'when the application has been updated according to our current support playbook' do
      it 'returns true' do
        application_form.candidate.update!(email_address: "deleted_on_user_request#{application_form.support_reference}@example.com")
        expect(service).to be true
      end
    end

    context 'when the application has not been deleted' do
      it 'returns false' do
        expect(service).to be false
      end
    end
  end
end
