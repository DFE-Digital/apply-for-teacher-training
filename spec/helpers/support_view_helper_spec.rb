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

  describe '#format_audit_value' do
    it 'returns the original value if the value is a simple string' do
      value = 'Bob'
      expect(format_audit_value(value)).to eq('Bob')
    end

    it 'returns the a serialized change if the value is a 2-part array (before and after values)' do
      value = %w[Bob Alice]
      expect(format_audit_value(value)).to eq('Bob → Alice')
    end
  end

  describe '#audit_value_present?' do
    it 'returns true for an array containing at least one non-empty value' do
      expect(audit_value_present?([nil, 'foo'])).to be true
    end

    it 'returns false for an array with only empty strings' do
      expect(audit_value_present?([nil, ''])).to be false
    end

    it 'returns false for an empty array' do
      expect(audit_value_present?([])).to be false
    end

    it 'returns true for a non-empty string value' do
      expect(audit_value_present?('foo')).to be true
    end

    it 'returns false for an empty string value' do
      expect(audit_value_present?('')).to be false
    end

    it 'returns false for a nil value' do
      expect(audit_value_present?(nil)).to be false
    end
  end
end
