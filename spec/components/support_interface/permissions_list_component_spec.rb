require 'rails_helper'

RSpec.describe SupportInterface::PermissionsListComponent do
  let(:ratifying_provider) { create(:provider) }
  let(:training_provider) { create(:provider) }
  let(:provider_relationship_permissions) do
    create(:provider_relationship_permissions,
           ratifying_provider: ratifying_provider,
           training_provider: training_provider,
           training_provider_can_make_decisions: true,
           ratifying_provider_can_make_decisions: true)
  end
  let(:tick_svg_path_shape) { 'M100 200a100 100 0 1 1 0-200 100 100 0 0 1 0 200zm-60-85l40 40 80-80-20-20-60 60-20-20-20 20z' }
  let(:cross_svg_path_shape) { 'M100 0a100 100 0 110 200 100 100 0 010-200zm30 50l-30 30-30-30-20 20 30 30-30 30 20 20 30-30 30 30 20-20-30-30 30-30-20-20z' }

  describe 'rendering permissions' do
    it 'displays all permissions has been assigned' do
      permission_model = create_permission_model
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('Manage organisational permissions – Yes')
      expect(result.css('path')[0].attribute('d').value).to eq(tick_svg_path_shape)
      expect(result.css('li').text).to include('Manage users – Yes')
      expect(result.css('path')[1].attribute('d').value).to eq(tick_svg_path_shape)
      expect(result.css('li').text).to include('Make decisions – Yes')
      expect(result.css('path')[2].attribute('d').value).to eq(tick_svg_path_shape)
      expect(result.css('li').text).to include('Access safeguarding information – Yes')
      expect(result.css('path')[3].attribute('d').value).to eq(tick_svg_path_shape)
      expect(result.css('li').text).to include('Access diversity information – Yes')
      expect(result.css('path')[4].attribute('d').value).to eq(tick_svg_path_shape)
    end

    it 'displays that manage permission has not been assigned' do
      permission_model = create_permission_model(manage_organisations: false)
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('Manage organisational permissions – No')
      expect(result.css('path')[0].attribute('d').value).to eq(cross_svg_path_shape)
    end

    it 'displays that manage users permission has not been assigned' do
      permission_model = create_permission_model(manage_users: false)
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('Manage users – No')
      expect(result.css('path')[1].attribute('d').value).to eq(cross_svg_path_shape)
    end

    it 'displays that make decisions permission has not been assigned' do
      permission_model = create_permission_model(make_decisions: false)
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('Make decisions – No')
      expect(result.css('path')[2].attribute('d').value).to eq(cross_svg_path_shape)
    end

    it 'displays that access safeguarding permission has not been assigned' do
      permission_model = create_permission_model(view_safeguarding_information: false)
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('Access safeguarding information – No')
      expect(result.css('path')[3].attribute('d').value).to eq(cross_svg_path_shape)
    end

    it 'displays that permission has not been assigned' do
      permission_model = create_permission_model(view_diversity_information: false)
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('Access diversity information – No')
      expect(result.css('path')[4].attribute('d').value).to eq(cross_svg_path_shape)
    end
  end

  describe 'rendering View applications only' do
    it 'shows an appropriate message when the user is viewing another user’s permissions' do
      permission_model = create(:provider_permissions)
      result = render_inline(described_class.new(permission_model))

      expect(result.css('li').text).to include('The user can only view applications')
      expect(result.css('li').text).not_to include('Manage organisational permissions')
      expect(result.css('li').text).not_to include('Make manage users')
      expect(result.css('li').text).not_to include('Make decisions')
      expect(result.css('li').text).not_to include('View safeguarding information')
      expect(result.css('li').text).not_to include('View diversity information')
    end
  end

  it 'renders ratifying providers who the permission also applies to' do
    permission_model = create(:provider_permissions, provider: training_provider, make_decisions: true)
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

  def create_permission_model(
    manage_organisations: true,
    manage_users: true,
    make_decisions: true,
    view_safeguarding_information: true,
    view_diversity_information: true
  )
    create(:provider_permissions,
           make_decisions: make_decisions,
           manage_users: manage_users,
           manage_organisations: manage_organisations,
           view_safeguarding_information: view_safeguarding_information,
           view_diversity_information: view_diversity_information)
  end
end
