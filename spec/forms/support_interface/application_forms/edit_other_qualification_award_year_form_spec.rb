require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditOtherQualificationAwardYearForm, :with_audited, type: :model do
  describe '#save' do
    let(:zendesk_ticket) { 'www.becomingateacher.zendesk.com/agent/tickets/example' }
    let(:qualification) { create(:other_qualification) }
    let(:form) { described_class.new(qualification) }

    it 'returns false if the award year is in the future' do
      invalid_award_year = Time.zone.now.year + 4

      form.assign_attributes(award_year: invalid_award_year, audit_comment: zendesk_ticket)

      expect(form).not_to be_valid
    end

    it 'returns false if no award year is provided' do
      form.assign_attributes(award_year: nil, audit_comment: zendesk_ticket)

      expect(form).not_to be_valid
    end

    it 'updates the qualification if valid' do
      valid_award_year = Time.zone.now.year

      form.assign_attributes(award_year: valid_award_year, audit_comment: zendesk_ticket)

      form.save!

      expect(form).to be_valid
      expect(qualification.award_year).to eq valid_award_year.to_s
      expect(qualification.audits.last.comment).to include(zendesk_ticket)
    end
  end
end
