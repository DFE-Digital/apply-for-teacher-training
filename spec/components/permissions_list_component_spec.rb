require 'rails_helper'

RSpec.describe PermissionsList do
  it 'renders permissions' do
    permission_model = create(:provider_permissions, manage_organisations: true)
    result = render_inline(described_class.new(permission_model))

    expect(result.css('li').text).to include('Manage organisations')
    expect(result.css('li').text).not_to include('View applications only')
  end

  it 'renders View applications only' do
    permission_model = create(:provider_permissions)
    result = render_inline(described_class.new(permission_model))

    expect(result.css('li').text).to include('View applications only')
    expect(result.css('li').text).not_to include('Manage organisations')
    expect(result.css('li').text).not_to include('Make manage users')
    expect(result.css('li').text).not_to include('Make decistions')
    expect(result.css('li').text).not_to include('View safeguarding information')
  end
end
