require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserPermissionsForm do
  let(:provider_permissions) { create(:provider_permissions) }

  describe 'validations' do
    it 'is valid when model is set' do
      expect(described_class.new(model: provider_permissions)).to be_valid
    end

    it 'is invalid without a model' do
      expect(described_class.new).to be_invalid
    end
  end

  describe '#from' do
    it 'generates a form object set to the model\'s permissions' do
      provider_permissions.update(make_decisions: true)
      form = described_class.from(provider_permissions)

      expect(form.manage_organisations).to be_falsy
      expect(form.manage_users).to be_falsy
      expect(form.view_safeguarding_information).to be_falsy
      expect(form.make_decisions).to be_truthy
    end
  end

  describe '#update_from_params' do
    it 'changes the form object permissions to match a hash' do
      form = described_class.new(
        manage_organisations: false,
        manage_users: true,
        view_safeguarding_information: false,
        make_decisions: true,
      )

      form.update_from_params view_safeguarding_information: true, manage_users: false

      expect(form.manage_organisations).to be_falsy
      expect(form.manage_users).to be_falsy
      expect(form.view_safeguarding_information).to be_truthy
      expect(form.make_decisions).to be_falsy
    end
  end

  describe '#save' do
    it 'updates and associated model with current form permissions' do
      provider_permissions.update(make_decisions: true)
      form = described_class.from(provider_permissions)

      form.view_safeguarding_information = true
      form.make_decisions = false

      form.save
      expect(provider_permissions.view_safeguarding_information).to be_truthy
      expect(provider_permissions.make_decisions).to be_falsy
    end

    it 'returns nil if there is no associated model' do
      form = described_class.new
      form.view_safeguarding_information = true
      expect(form.save).to be_nil
    end
  end
end
