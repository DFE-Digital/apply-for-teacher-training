require 'rails_helper'

RSpec.describe AssociatedProvidersPermissionsListComponent do
  let(:ratifying_provider) { create(:provider) }
  let(:training_provider) { create(:provider) }

  context 'when viewing as a training provider' do
    it 'renders which ratifying providers the permission applies to' do
      create_provider_relationship_permissions

      result = render_inline(described_class.new(provider: training_provider, permission_name: 'make_decisions'))

      expect(result.text).to include('Applies to courses ratified by:')
      expect(result.css('li').text).to include(ratifying_provider.name.to_s)
    end

    it 'renders which ratifying providers the permission does not apply to' do
      create_provider_relationship_permissions.update!(training_provider_can_make_decisions: false)

      result = render_inline(described_class.new(provider: training_provider, permission_name: 'make_decisions'))

      expect(result.text).to include('Does not apply to courses ratified by:')
      expect(result.css('li').text).to include(ratifying_provider.name.to_s)
    end

    it 'does not change based on what the ratifying provider can do' do
      create_provider_relationship_permissions.update!(ratifying_provider_can_make_decisions: false)

      result = render_inline(described_class.new(provider: training_provider, permission_name: 'make_decisions'))

      expect(result.text).to include('Applies to courses ratified by:')
      expect(result.css('li').text).to include(ratifying_provider.name.to_s)
    end
  end

  context 'when viewing as a ratifying provider' do
    it 'renders which training providers the permission applies to' do
      create_provider_relationship_permissions

      result = render_inline(described_class.new(provider: ratifying_provider, permission_name: 'make_decisions'))

      expect(result.text).to include('Applies to courses run by:')
      expect(result.css('li').text).to include(training_provider.name.to_s)
    end

    it 'renders which training providers the permission does not apply to' do
      create_provider_relationship_permissions.update!(ratifying_provider_can_make_decisions: false)

      result = render_inline(described_class.new(provider: ratifying_provider, permission_name: 'make_decisions'))

      expect(result.text).to include('Does not apply to courses run by:')
      expect(result.css('li').text).to include(training_provider.name.to_s)
    end

    it 'does not change based on what the training provider can do' do
      create_provider_relationship_permissions.update!(training_provider_can_make_decisions: false)

      result = render_inline(described_class.new(provider: ratifying_provider, permission_name: 'make_decisions'))

      expect(result.text).to include('Applies to courses run by:')
      expect(result.css('li').text).to include(training_provider.name.to_s)
    end
  end

  def create_provider_relationship_permissions
    create(
      :provider_relationship_permissions,
      ratifying_provider: ratifying_provider,
      training_provider: training_provider,
      training_provider_can_make_decisions: true,
      ratifying_provider_can_make_decisions: true,
    )
  end
end
