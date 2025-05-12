require 'rails_helper'

RSpec.describe SupportInterface::EmailSubscriptionForm, type: :model do
  subject(:form) { described_class.new(form_data) }

  let(:form_data) do
    {
      unsubscribed_from_emails: true,
      audit_comment: 'too much spam',
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:unsubscribed_from_emails) }
    it { is_expected.to validate_presence_of(:audit_comment) }
  end

  describe '.build_from_application' do
    let(:application_form) { create(:application_form, candidate: create(:candidate, unsubscribed_from_emails: true)) }

    it 'creates an object based on the provided ApplicationForm' do
      form = described_class.build_from_application(application_form)
      expect(form.unsubscribed_from_emails).to be(true)
    end
  end

  describe '#save', :with_audited do
    let(:candidate) { create(:candidate, unsubscribed_from_emails: false) }
    let(:application_form) { create(:application_form, candidate:) }

    context 'when form is invalid' do
      it 'returns false' do
        form = described_class.new
        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when form is valid' do
      it 'updates the candidate with the new value and audits' do
        expect(form.save(application_form)).to be(true)
        expect(application_form.candidate.reload.unsubscribed_from_emails).to be(true)

        audit = candidate.audits.find do |a|
          a.audited_changes == { 'unsubscribed_from_emails' => [false, true] }
        end

        expect(audit.comment).to eq('too much spam')
      end
    end
  end
end
