require 'rails_helper'

RSpec.describe DataMigrations::SetMissingProviderRelationshipPermissions do
  it 'creates missing provider_relationship_permission' do
    courses_with_no_provider_relationships = create_list(:course, 3, :with_accredited_provider)
    create(:course, :with_provider_relationship_permissions)

    expect {
      described_class.new.change
    }.to change(ProviderRelationshipPermissions, :count).by(courses_with_no_provider_relationships.count)
  end

  it 'does nothing if all courses have provider_relationship_permissions correctly setup' do
    create(:course, :with_provider_relationship_permissions)
    create(:course, :with_provider_relationship_permissions)

    expect {
      described_class.new.change
    }.to change(ProviderRelationshipPermissions, :count).by(0)
  end

  it 'does nothing if the course has no accredited provider or a match provider and accredited provider' do
    provider = build(:provider)
    create(:course, provider: provider, accredited_provider: provider)
    create(:course, provider: provider, accredited_provider: nil)

    expect {
      described_class.new.change
    }.to change(ProviderRelationshipPermissions, :count).by(0)
  end
end
