require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserEditPermissionsForm do
  let(:provider_permissions) { create(:provider_permissions) }
  let(:provider) { provider_permissions.provider }
  let(:view_applications_only) { 'false' }
  let(:permissions) { %w[manage_users] }
  let(:params) do
    {
      'provider_permissions' => {
        provider.id.to_s => {
          'view_applications_only' => view_applications_only,
          'permissions' => permissions,
        },
      },
    }
  end

  describe 'validations' do
    it 'is valid when model is set' do
      expect(described_class.build_from_model(provider_permissions)).to be_valid
    end

    it 'is invalid without a model' do
      expect(described_class.new).to be_invalid
    end
  end

  describe '#build_from_model' do
    it 'generates a form object set to the model\'s permissions' do
      provider_permissions.update(make_decisions: true)
      form = described_class.build_from_model(provider_permissions)

      expect(form.provider_permissions[provider.id.to_s]['permissions']).to contain_exactly('make_decisions')
    end
  end

  describe '#update_from_params' do
    it 'changes the form object permissions to match a hash' do
      form = described_class.build_from_model(provider_permissions)

      form.update_from_params params

      expect(form.provider_permissions[provider.id.to_s]['permissions']).to contain_exactly('manage_users')
    end
  end

  describe '#save' do
    let(:permissions) { %w[view_safeguarding_information] }

    it 'updates and associated model with current form permissions' do
      provider_permissions.update(make_decisions: true)
      form = described_class.build_from_model(provider_permissions)

      form.update_from_params params

      form.save
      expect(provider_permissions.view_safeguarding_information).to be_truthy
      expect(provider_permissions.make_decisions).to be_falsy
    end

    it 'returns nil if there is no associated model' do
      form = described_class.new
      form.update_from_params params
      expect(form.save).to be_nil
    end
  end
end
