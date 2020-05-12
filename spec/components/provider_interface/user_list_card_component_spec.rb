require 'rails_helper'

RSpec.describe ProviderInterface::UserListCardComponent do
  include CourseOptionHelpers

  let(:providers) do
    [
      build_stubbed(:provider, name: 'Hoth Teacher Training'),
      build_stubbed(:provider, name: 'Yavin Teacher Training'),
      build_stubbed(:provider, name: 'Endor Teacher Training'),
    ]
  end

  let(:provider_user) { build_stubbed(:provider_user, id: 111, providers: providers) }
  let(:instance) { described_class.new(provider_user: provider_user, providers: providers) }
  let(:result) { render_inline instance }
  let(:card) { result.css('.app-application-card').to_html }

  describe 'rendering' do
    it 'renders the name of the provider user' do
      expect(card).to include(provider_user.full_name)
    end

    it 'renders the provider user\'s email' do
      expect(card).to include(provider_user.email_address)
    end

    it 'renders the name of the first provider and a cardinal number representing the rest' do
      expect(card).to include('Hoth Teacher Training and two more')
    end
  end

  describe '#providers_text' do
    context 'when one provider exists' do
      let(:providers) { [build_stubbed(:provider)] }

      it 'renders the name of the first provider' do
        expect(instance.providers_text).to eq(providers.first.name)
      end
    end

    context 'when more than one provider exists' do
      it 'renders the name of the first provider and cardinal number for others' do
        expect(instance.providers_text).to eq('Hoth Teacher Training and two more')
      end
    end
  end
end
