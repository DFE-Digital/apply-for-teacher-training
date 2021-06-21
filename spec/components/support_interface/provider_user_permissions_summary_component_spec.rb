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
end
