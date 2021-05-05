require 'rails_helper'

RSpec.describe DataMigrations::RemoveDuplicateProvider do
  let(:provider) { create(:provider, name: 'Test Provider 001') }
  let(:duplicate_provider) { create(:provider, name: 'Test Provider 001') }
  let!(:provider_relationship_permissions) { create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: duplicate_provider) }
  let!(:self_ratified_course) { create(:course, provider: provider, accredited_provider: duplicate_provider) }
  let!(:other_course) { create(:course, provider: provider, accredited_provider: create(:provider)) }

  it 'makes courses accredited by the duplicate provider self-ratified by the training provider' do
    DataMigrations::RemoveDuplicateProvider.new.change

    expect(self_ratified_course.reload.accredited_provider).to be_nil
    expect(other_course.reload.accredited_provider).not_to be_nil
  end

  it 'destroys the relationship between the training provider and the duplicate' do
    expect { DataMigrations::RemoveDuplicateProvider.new.change }.to change(ProviderRelationshipPermissions, :count).by(-1)
  end

  it 'destroys the duplicate provider' do
    expect { DataMigrations::RemoveDuplicateProvider.new.change }.to change(Provider, :count).by(-1)
  end
end
