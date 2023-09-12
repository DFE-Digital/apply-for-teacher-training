require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditOtherQualificationGradeForm, :with_audited, type: :model do
  describe '#save' do
    let(:zendesk_ticket) { 'www.becomingateacher.zendesk.com/agent/tickets/example' }
    let(:qualification) { create(:other_qualification) }
    let(:form) { described_class.new(qualification) }

    it 'returns false if the grade is not valid' do
      invalid_grade = 'nonsense'

      form.assign_attributes(grade: invalid_grade, audit_comment: zendesk_ticket)

      expect(form).not_to be_valid
    end

    it 'returns false if no grade is provided' do
      form.assign_attributes(grade: nil, audit_comment: zendesk_ticket)

      expect(form).not_to be_valid
    end

    it 'updates the qualification if valid' do
      valid_grade = 'A'

      form.assign_attributes(grade: valid_grade, audit_comment: zendesk_ticket)

      form.save!

      expect(form).to be_valid
      expect(qualification.grade).to eq valid_grade
      expect(qualification.audits.last.comment).to include(zendesk_ticket)
    end
  end
end
