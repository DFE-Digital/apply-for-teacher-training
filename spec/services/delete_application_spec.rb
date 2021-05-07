require 'rails_helper'

RSpec.describe DeleteApplication do
  let(:support_user) { create(:support_user) }
  let(:application_form) do
    create(
      :completed_application_form,
      application_choices_count: 3,
      work_experiences_count: 2,
      volunteering_experiences_count: 2,
      references_count: 2,
      full_work_history: true,
    )
  end
  let(:zendesk_url) { 'https://becomingateacher.zendesk.com/agent/tickets/1234' }
  let(:service) do
    described_class.new(
      actor: support_user,
      application_form: application_form,
      zendesk_url: zendesk_url,
    )
  end

  describe '#call!', with_audited: true do
    it 'raises error if application has been submitted to providers' do
      application_choice = application_form.application_choices.first
      SendApplicationToProvider.call(application_choice)
      expect { service.call! }.to raise_error('Application has been sent to providers')
    end

    it 'deletes all personal information from the application form' do
      service.call!

      application_form.reload
      DeleteApplication::APPLICATION_FORM_FIELDS_TO_REDACT.each do |attr|
        expect(application_form.send(attr)).to be_blank
      end
    end

    it 'does not remove their application choices' do
      service.call!

      application_form.reload
      expect(application_form.application_choices.count).to eq(3)
    end

    it 'removes associations which can leak personal information' do
      service.call!

      application_form.reload
      DeleteApplication::ASSOCIATIONS_TO_DESTROY.each do |assoc|
        expect(application_form.send(assoc).count).to be_zero
      end
    end

    it 'replaces all audits with a single entry documenting the deletion' do
      service.call!

      application_form.reload
      expect(application_form.own_and_associated_audits.count).to eq(1)

      audit = application_form.own_and_associated_audits.first
      expect(audit.user).to eq(support_user)
      expect(audit.comment).to eq("Data deletion request: #{zendesk_url}")
    end
  end
end
