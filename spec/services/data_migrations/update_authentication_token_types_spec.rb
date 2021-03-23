require 'rails_helper'

RSpec.describe DataMigrations::UpdateAuthenticationTokenTypes do
  it 'updates authentication tokens with user type `DataAPIUser` to `ServiceAPIUser`' do
    authentication_token = create(:authentication_token)

    # Since the DataAPIUser was removed, we have to set this outside the factory to avoid callbacks
    authentication_token.update_column(:user_type, 'DataAPIUser')
    described_class.new.change

    expect(authentication_token.reload.user_type).to eq('ServiceAPIUser')
  end

  it 'does not update other authentication tokens with a different user type' do
    authentication_token = create(:authentication_token)
    described_class.new.change

    expect(authentication_token.reload.user_type).to eq('SupportUser')
  end
end
