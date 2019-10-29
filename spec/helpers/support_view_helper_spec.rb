require 'rails_helper'

RSpec.describe SupportViewHelper, type: :helper do
  describe '#audit_entry_label' do
    it 'returns a valid label for a candidate logged entry' do
      candidate = build :candidate, email_address: 'jim@example.com'
      audit = instance_double(Audited::Audit, user: candidate, auditable_type: 'ApplicationForm', action: 'create')

      expect(audit_entry_label(audit)).to eq('Create Application Form - jim@example.com (Candidate)')
    end

    it 'returns a valid label for a Vendor API logged entry' do
      vendor_api_user = build :vendor_api_user, email_address: 'derek@example.com'
      audit = instance_double(Audited::Audit, user: vendor_api_user, auditable_type: 'ApplicationForm', action: 'update')

      expect(audit_entry_label(audit)).to eq('Update Application Form - derek@example.com (Vendor API)')
    end

    it 'returns a valid label for an entry without a user' do
      audit = instance_double(Audited::Audit, user: nil, auditable_type: 'ApplicationForm', action: 'update')

      expect(audit_entry_label(audit)).to eq('Update Application Form - (Unknown User)')
    end
  end
end
