require 'rails_helper'

RSpec.describe ProviderInterface::ProviderPermissionsListComponent do
  let(:providers) do
    [
      build_stubbed(:provider, id: 10),
      build_stubbed(:provider, id: 11),
      build_stubbed(:provider, id: 12),
      build_stubbed(:provider, id: 13),
    ]
  end

  let(:provider_permissions) do
    [
      build_stubbed(:provider_permissions, id: 1, manage_users: true, provider: providers[0]),
      build_stubbed(:provider_permissions, id: 2, provider: providers[1]),
      build_stubbed(:provider_permissions, id: 3, manage_users: true, provider: providers[2]),
      build_stubbed(:provider_permissions, id: 4, manage_users: true, provider: providers[3]),
    ]
  end

  let(:possible_permissions) do
    provider_permissions[0..2]
  end

  it 'renders the correct permissions per provider' do
    result = render_inline(
      described_class.new(
        provider_permissions: provider_permissions,
        possible_permissions: possible_permissions,
      ),
    )

    expect(result.text).to include(providers[0].name)
    expect(result.css('#provider-10-enabled-permissions').text).to include('Manage users')
    expect(result.text).to include(providers[1].name)
    expect(result.css('#provider-11-enabled-permissions').text).to include('No permissions')
    expect(result.text).to include(providers[2].name)
    expect(result.css('#provider-12-enabled-permissions').text).to include('Manage users')
  end

  it 'does not expose permissions for non visible providers' do
    result = render_inline(
      described_class.new(
        provider_permissions: provider_permissions,
        possible_permissions: possible_permissions,
      ),
    )

    expect(result.text).not_to include(providers[3].name)
  end
end
