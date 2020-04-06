require 'rails_helper'

RSpec.describe ProviderInterface::UserListCardComponent do
  include CourseOptionHelpers

  let(:providers) do
    [
      create(:provider,
             code: 'ABC',
             name: 'Hoth Teacher Training'),
      create(:provider,
             code: 'DEF',
             name: 'Yavin Teacher Training'),
      create(:provider,
             code: 'GHI',
             name: 'Endor Teacher Training')
    ]
  end

  let(:provider_user) do
    create(:provider_user,
           first_name: 'Wesley',
           last_name: 'Antellies',
           email_address: 'wes@test.com',
           providers: providers)
  end

  let(:result) { render_inline described_class.new(provider_user: provider_user) }

  let(:card) { result.css('.app-application-card').to_html }

  describe 'rendering' do
    it 'renders the name of the provider user' do
      expect(card).to include('Wesley Antellies')
    end

    it 'renders the provider user\'s email' do
      expect(card).to include('wes@test.com')
    end

    it 'renders the name of the first provider the provider user has management rights for and a cardinal number representing the rest' do
      expect(card).to include('Hoth Teacher Training and two more')
    end
  end
end
