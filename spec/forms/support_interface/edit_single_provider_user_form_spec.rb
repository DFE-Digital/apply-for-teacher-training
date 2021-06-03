require 'rails_helper'

RSpec.describe SupportInterface::EditSingleProviderUserForm do
  let(:provider) { build_stubbed(:provider, id: 2) }
  let(:provider_permissions) do
    {
      provider_permission: {
        provider_id: provider.id,
      },
    }
  end
  let(:form_params) do
    {
      provider_permissions: provider_permissions,
      provider_id: provider.id,
    }
  end

  subject(:provider_user_form) { described_class.new(form_params) }

  describe 'validations' do
    context 'provider permissions must be present' do
      let(:provider_permissions) { {} }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:provider_permissions]).not_to be_empty
      end
    end
  end
end
