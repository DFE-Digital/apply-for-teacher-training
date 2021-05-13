require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsListComponent do
  subject(:component) do
    described_class.new(
      permissions_model: create(:provider_relationship_permissions),
      change_link_builder: ProviderInterface::ProviderRelationshipEditChangeLinkBuilder,
    )
  end

  it 'renders' do
    expect { render_inline(component) }.not_to raise_error
  end
end
