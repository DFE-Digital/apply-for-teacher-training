require 'rails_helper'

RSpec.describe SupportUser, type: :model do
  describe 'validations' do
    it 'flags email addresses that differ only by case as duplicates' do
      create :support_user, email_address: 'bob@example.com'
      duplicate_support_user = build :support_user, email_address: 'Bob@example.com'
      expect(duplicate_support_user).not_to be_valid
    end
  end

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

  describe '#load_from_session' do
    let(:dsi_user) { build(:dfe_sign_in_user) }

    it 'obtains impersonated_provider_user information from DfESignInUser' do
      provider_user = create(:provider_user)
      allow(dsi_user).to receive(:impersonated_provider_user).and_return(provider_user)
      allow(DfESignInUser).to receive(:load_from_session).and_return(dsi_user)

      create(
        :support_user,
        dfe_sign_in_uid: dsi_user.dfe_sign_in_uid,
        email_address: dsi_user.email_address,
        first_name: dsi_user.first_name,
        last_name: dsi_user.last_name,
      )

      support_user = SupportUser.load_from_session({})
      expect(support_user.dfe_sign_in_uid).to eq(dsi_user.dfe_sign_in_uid)
      expect(support_user.impersonated_provider_user).to eq(provider_user)
    end

    it 'returns nil if there is no associated SupportUser' do
      allow(DfESignInUser).to receive(:load_from_session).and_return(dsi_user)
      support_user = SupportUser.load_from_session({})
      expect(support_user).to be_nil
    end
  end
end
