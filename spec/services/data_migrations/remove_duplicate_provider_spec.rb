require 'rails_helper'

RSpec.describe DataMigrations::RemoveDuplicateProvider do
  context 'with duplicate providers related via organisation permissions' do
    let(:provider) { create(:provider, :with_signed_agreement, name: 'Test Provider 001') }
    let(:duplicate_provider) { create(:provider, name: 'Test Provider 001') }
    let!(:provider_user) { create(:provider_user, providers: [provider, duplicate_provider]) }
    let!(:provider_relationship_permissions) { create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: duplicate_provider) }
    let!(:duplicate_provider_agreements) { create(:provider_agreement, provider: duplicate_provider, provider_user: provider_user) }

    let!(:self_ratified_course) { create(:course, provider: provider, accredited_provider: duplicate_provider) }
    let!(:other_course) { create(:course, provider: provider, accredited_provider: create(:provider)) }

    it 'makes courses accredited by the duplicate provider self-ratified by the training provider' do
      described_class.new.change

      expect(self_ratified_course.reload.accredited_provider).to be_nil
      expect(other_course.reload.accredited_provider).not_to be_nil
    end

    it 'destroys the relationship between the training provider and the duplicate' do
      expect { described_class.new.change }.to change(ProviderRelationshipPermissions, :count).by(-1)
    end

    it 'destroys the duplicate provider' do
      expect { described_class.new.change }.to change(Provider, :count).by(-1)
    end

    it 'destroys the provider agreement for the duplicate provider' do
      expect { described_class.new.change }.to change(ProviderAgreement, :count).by(-1)
    end
  end

  context 'with duplicate providers and additional permissions for the ratifying provider' do
    it 'does nothing' do
      provider = create(:provider, name: 'Test Provider 002')
      duplicate_provider = create(:provider, name: 'Test Provider 002')
      course = create(:course, provider: provider, accredited_provider: duplicate_provider)
      create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: duplicate_provider)
      create(:provider_relationship_permissions, training_provider: create(:provider), ratifying_provider: duplicate_provider)

      expect { described_class.new.change }.not_to change(ProviderRelationshipPermissions, :count)
      expect(course.reload.accredited_provider).not_to be_nil
    end
  end

  context 'with unrelated courses ratified by the ratifying provider' do
    it 'does nothing' do
      provider = create(:provider, name: 'Test Provider 002')
      another_provider = create(:provider, name: 'Another Test Provider')
      duplicate_provider = create(:provider, name: 'Test Provider 002')
      create(:course, provider: provider, accredited_provider: duplicate_provider)
      ratified_course = create(:course, provider: another_provider, accredited_provider: duplicate_provider)
      create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: duplicate_provider)
      create(:provider_relationship_permissions, training_provider: another_provider, ratifying_provider: duplicate_provider)

      expect { described_class.new.change }.not_to change(ProviderRelationshipPermissions, :count)
      expect(ratified_course.reload.accredited_provider).not_to be_nil
    end
  end

  context 'with users who only belong to the duplicate provider' do
    it 'does not remove the provider' do
      provider = create(:provider, name: 'Test Provider 002')
      duplicate_provider = create(:provider, name: 'Test Provider 002')
      create(:provider_user, providers: [duplicate_provider])
      create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: duplicate_provider)

      expect { described_class.new.change }.not_to change(Provider, :count)
    end
  end
end
