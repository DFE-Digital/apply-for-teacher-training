require 'rails_helper'

RSpec.describe SupportUser, type: :model do
  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      support_user = create :support_user, email_address: 'Bob.Roberts@example.com'
      expect(support_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end
end
