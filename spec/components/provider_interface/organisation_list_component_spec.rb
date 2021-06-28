require 'rails_helper'

RSpec.describe ProviderInterface::OrganisationListComponent do
  let(:provider) { create(:provider) }
  let(:providers_user_belongs_to) { [] }
  let(:provider_user) { create(:provider_user, providers: providers_user_belongs_to) }
  let(:render) { render_inline(described_class.new(provider: provider, current_provider_user: provider_user)) }

  context 'user cannot manage organisations' do
    context 'with set up ratifying providers permissions' do
      let!(:permission) do
        create(
          :provider_relationship_permissions,
          ratifying_provider: provider,
        )
      end

      it 'renders text for uneditable permissions' do
        expect(render.text).to include("Only #{permission.training_provider.name} can change permissions")
      end
    end

    context 'with ratifying providers not set up' do
      let!(:permission) do
        create(
          :provider_relationship_permissions,
          ratifying_provider: provider,
          setup_at: nil,
        )
      end

      it 'renders text for non set up permissions' do
        expect(render.text).to include("#{permission.training_provider.name} have not set up permissions yet")
      end
    end
  end

  context 'user can manage organisations' do
    let(:provider_user) { create(:provider_user, :with_manage_organisations, providers: providers_user_belongs_to) }

    context 'with set up training providers' do
      let(:providers_user_belongs_to) { [provider] }
      let!(:permission) do
        create(
          :provider_relationship_permissions,
          training_provider: provider,
        )
      end

      it 'renders text for editable permissions' do
        expect(render.text).to include("#{permission.training_provider.name} and #{permission.ratifying_provider.name}")
      end
    end

    context 'with set up ratifying providers' do
      let(:providers_user_belongs_to) { [provider, training_provider] }
      let(:training_provider) { create(:provider) }
      let!(:permission) do
        create(
          :provider_relationship_permissions,
          training_provider: training_provider,
          ratifying_provider: provider,
        )
      end

      it 'renders text for editable permissions' do
        expect(render.text).to include("#{permission.training_provider.name} and #{permission.ratifying_provider.name}")
      end

      it 'does not render text for non editable permissions' do
        expect(render.text).not_to include("Only #{permission.training_provider.name} can change permissions")
      end
    end

    context 'with training providers not set up' do
      let(:providers_user_belongs_to) { [provider] }
      let!(:permission) do
        create(
          :provider_relationship_permissions,
          training_provider: provider,
          setup_at: nil,
        )
      end

      it 'does not render text for editable permissions' do
        expect(render.text).not_to include("#{permission.training_provider.name} and #{permission.ratifying_provider.name}")
      end
    end

    context 'with ratifying providers not set up' do
      let(:providers_user_belongs_to) { [provider, training_provider] }
      let(:training_provider) { create(:provider) }
      let!(:permission) do
        create(
          :provider_relationship_permissions,
          training_provider: training_provider,
          ratifying_provider: provider,
          setup_at: nil,
        )
      end

      it 'does not render text for editable permissions' do
        expect(render.text).not_to include("#{permission.training_provider.name} and #{permission.ratifying_provider.name}")
      end

      it 'does not render text for non set up permissions' do
        expect(render.text).not_to include("#{permission.training_provider.name} have not set up permissions yet")
      end
    end

    context 'with multiple relationships' do
      let(:ratifying_provider1) { create(:provider, name: 'XYZ academy') }
      let(:ratifying_provider2) { create(:provider, name: 'ABC academy') }
      let(:permissions1) { create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: ratifying_provider1) }
      let(:permissions2) { create(:provider_relationship_permissions, training_provider: provider, ratifying_provider: ratifying_provider2) }
      let!(:permissions) { [permissions1, permissions2] }

      it 'orders relationships consistently' do
        instance = described_class.new(provider: provider, current_provider_user: provider_user)
        expect(instance.training_permissions).to eq(permissions.reverse)
      end
    end
  end
end
