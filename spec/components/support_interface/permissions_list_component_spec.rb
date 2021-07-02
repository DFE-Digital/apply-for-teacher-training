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
  let(:permission_model) do
    create(:provider_permissions,
           set_up_interviews: set_up_interviews,
           make_decisions: make_decisions,
           manage_users: manage_users,
           manage_organisations: manage_organisations,
           view_safeguarding_information: view_safeguarding_information,
           view_diversity_information: view_diversity_information)
  end
  let(:manage_organisations) { true }
  let(:manage_users) { true }
  let(:set_up_interviews) { true }
  let(:make_decisions) { true }
  let(:view_safeguarding_information) { true }
  let(:view_diversity_information) { true }

  before do
    FeatureFlag.activate(:interview_permissions)
  end

  describe 'rendering permissions' do
    context 'when all permissions have been assigned' do
      it 'displays Yes on all' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Manage organisational permissions – Yes')
        expect(result.css('path')[0].attribute('d').value).to eq(tick_svg_path_shape)
        expect(result.css('li').text).to include('Manage users – Yes')
        expect(result.css('path')[1].attribute('d').value).to eq(tick_svg_path_shape)
        expect(result.css('li').text).to include('Set up interviews – Yes')
        expect(result.css('path')[2].attribute('d').value).to eq(tick_svg_path_shape)
        expect(result.css('li').text).to include('Make decisions – Yes')
        expect(result.css('path')[3].attribute('d').value).to eq(tick_svg_path_shape)
        expect(result.css('li').text).to include('Access safeguarding information – Yes')
        expect(result.css('path')[4].attribute('d').value).to eq(tick_svg_path_shape)
        expect(result.css('li').text).to include('Access diversity information – Yes')
        expect(result.css('path')[5].attribute('d').value).to eq(tick_svg_path_shape)
      end
    end

    context 'when Manage Organisations has not been assigned' do
      let(:manage_organisations) { false }

      it 'reflects that the permission has not been assigned' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Manage organisational permissions – No')
        expect(result.css('path')[0].attribute('d').value).to eq(cross_svg_path_shape)
      end
    end

    context 'when Manage Users has not been assigned' do
      let(:manage_users) { false }

      it 'reflects that the permission has not been assigned' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Manage users – No')
        expect(result.css('path')[1].attribute('d').value).to eq(cross_svg_path_shape)
      end
    end

    context 'when Set up interviews has not been assigned' do
      let(:set_up_interviews) { false }

      it 'reflects that the permission has not been assigned' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Set up interviews – No')
        expect(result.css('path')[2].attribute('d').value).to eq(cross_svg_path_shape)
      end
    end

    context 'when Make Decisions has not been assigned' do
      let(:make_decisions) { false }

      it 'reflects that the permission has not been assigned' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Make decisions – No')
        expect(result.css('path')[3].attribute('d').value).to eq(cross_svg_path_shape)
      end
    end

    context 'when View Safeguarding Information has not been assigned' do
      let(:view_safeguarding_information) { false }

      it 'reflects that the permission has not been assigned' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Access safeguarding information – No')
        expect(result.css('path')[4].attribute('d').value).to eq(cross_svg_path_shape)
      end
    end

    context 'when View Diversity Information has not been assigned' do
      let(:view_diversity_information) { false }

      it 'displays that permission has not been assigned' do
        result = render_inline(described_class.new(permission_model))

        expect(result.css('li').text).to include('Access diversity information – No')
        expect(result.css('path')[5].attribute('d').value).to eq(cross_svg_path_shape)
      end
    end
  end

  describe 'when the user has no permissions set' do
    it 'they cannot see user permissions' do
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
end
