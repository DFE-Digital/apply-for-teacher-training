require 'rails_helper'

RSpec.describe SupportInterface::ProviderUserPermissionsSummaryComponent do
  let(:provider) { create(:provider, name: 'Provider One') }

  it 'renders a summary of provider permissions' do
    provider_user = create(:provider_user, :with_manage_users, providers: [provider])

    rendered_component_text = render_inline(described_class.new(provider_user)).text

    expect(rendered_component_text).to include('Provider One')
    expect(rendered_component_text).to include('Manage users')
    expect(rendered_component_text).to include('Change')
  end

  it 'orders permissions by provider name' do
    another_provider = create(:provider, name: 'Another Provider')
    provider_user = create(:provider_user, :with_manage_users, providers: [provider, another_provider])

    rendered_component = render_inline(described_class.new(provider_user))

    expect(rendered_component.css('.govuk-summary-list__key').text).to eq("#{another_provider.name_and_code}(Provider permissions)#{provider.name_and_code}(Provider permissions)")
  end

  it 'renders an empty state when there are no permissions' do
    provider_user = create(:provider_user)

    rendered_component_text = render_inline(described_class.new(provider_user)).text

    expect(rendered_component_text).to include('This user does not have access to any providers')
  end
end
