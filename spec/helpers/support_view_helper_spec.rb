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

  describe '#audit_attribute_value' do
    it 'returns the original value if the value is a simple string' do
      value = 'Bob'
      expect(audit_attribute_value(value)).to eq('Bob')
    end

    it 'returns the a serialized change if the value is a 2-part array (before and after values)' do
      value = %w[Bob Alice]
      expect(audit_attribute_value(value)).to eq('Bob &rarr; Alice')
    end
  end
end
