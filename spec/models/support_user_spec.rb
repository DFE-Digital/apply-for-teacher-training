require 'rails_helper'

RSpec.describe SupportUser, type: :model do
  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      support_user = create :support_user, email_address: 'Bob.Roberts@example.com'
      expect(support_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end

  describe 'auditing', with_audited: true do
    it 'records an audit entry when creating and updating a new SupportUser' do
      support_user = create :support_user, first_name: 'Bob'
      expect(support_user.audits.count).to eq 1
      support_user.update(first_name: 'Alice')
      expect(support_user.audits.count).to eq 2
    end
  end
end
