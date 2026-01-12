require 'rails_helper'

RSpec.describe SupportUser do
  describe 'validations' do
    let!(:existing_support_user) { create(:support_user) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
  end

  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      support_user = create(:support_user, email_address: 'Bob.Roberts@example.com')
      expect(support_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end

  describe 'auditing', :with_audited do
    it 'records an audit entry when creating and updating a new SupportUser' do
      support_user = create(:support_user, first_name: 'Bob')
      expect(support_user.audits.count).to eq 1
      support_user.update(first_name: 'Alice')
      expect(support_user.audits.count).to eq 2
    end
  end
end
