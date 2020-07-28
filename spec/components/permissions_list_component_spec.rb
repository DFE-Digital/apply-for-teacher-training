require 'rails_helper'

RSpec.describe PermissionsList do
  let(:ratifying_provider) { create(:provider) }
  let(:training_provider) { create(:provider) }
  let(:provider_relationship_permissions) do
    create(:provider_relationship_permissions,
           ratifying_provider: ratifying_provider,
           training_provider: training_provider,
           training_provider_can_make_decisions: true,
           ratifying_provider_can_make_decisions: true)
  end

  it 'renders permissions' do
    permission_model = create(:provider_permissions, manage_organisations: true)
    result = render_inline(described_class.new(permission_model))

    expect(result.css('li').text).to include('Manage organisations')
    expect(result.css('li').text).not_to include('The user can only view applications')
  end

  it 'renders View applications only' do
    permission_model = create(:provider_permissions)
    result = render_inline(described_class.new(permission_model))

    expect(result.css('li').text).to include('The user can only view applications')
    expect(result.css('li').text).not_to include('Manage organisations')
    expect(result.css('li').text).not_to include('Make manage users')
    expect(result.css('li').text).not_to include('Make decistions')
    expect(result.css('li').text).not_to include('Access safeguarding information')
  end

  it 'renders ratifying providers who the permission also applies to' do
    permission_model = create(:provider_permissions,
                              provider: training_provider,
                              make_decisions: true)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model))

    expect(result.text).to include('Applies to courses ratified by:')
    expect(result.css('li').text).to include(ratifying_provider.name.to_s)
  end

  it 'renders training providers who the permission also applies to' do
    permission_model = create(:provider_permissions,
                              provider: ratifying_provider,
                              make_decisions: true)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model))

    expect(result.text).to include('Applies to courses run by:')
    expect(result.css('li').text).to include(training_provider.name.to_s)
  end
end
