require 'rails_helper'

RSpec.describe PermissionsListComponent do
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
    permission_model = create(:provider_permissions, manage_organisations: true, set_up_interviews: true)
    result = render_inline(described_class.new(permission_model, user_is_viewing_their_own_permissions: false))

    expect(result.css('li').text).to include('Manage organisational permissions')
    expect(result.css('li').text).to include('Set up interviews')
    expect(result.css('li').text).not_to include('The user can only view applications')
  end

  describe 'rendering View applications only' do
    it 'shows an appropriate message when the user is viewing another user’s permissions' do
      permission_model = create(:provider_permissions)
      result = render_inline(described_class.new(permission_model, user_is_viewing_their_own_permissions: false))

      expect(result.css('li').text).to include('The user can only view applications')
      expect(result.css('li').text).not_to include('Manage organisational permissions')
      expect(result.css('li').text).not_to include('Make manage users')
      expect(result.css('li').text).not_to include('Make decistions')
      expect(result.css('li').text).not_to include('View safeguarding information')
      expect(result.css('li').text).not_to include('View diversity information')
    end

    it 'shows an appropriate message when the user is viewing their own permissions' do
      permission_model = create(:provider_permissions)
      result = render_inline(described_class.new(permission_model, user_is_viewing_their_own_permissions: true))
      expect(result.css('li').text).to include('You can only view applications')
    end
  end

  it 'renders ratifying providers who the permission also applies to' do
    permission_model = create(:provider_permissions,
                              provider: training_provider,
                              make_decisions: true)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model, user_is_viewing_their_own_permissions: false))

    expect(result.text).to include('Applies to courses ratified by:')
    expect(result.css('li').text).to include(ratifying_provider.name.to_s)
  end

  it 'renders training providers who the permission also applies to' do
    permission_model = create(:provider_permissions,
                              provider: ratifying_provider,
                              make_decisions: true)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model, user_is_viewing_their_own_permissions: false))

    expect(result.text).to include('Applies to courses run by:')
    expect(result.css('li').text).to include(training_provider.name.to_s)
  end
end
