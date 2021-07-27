require 'rails_helper'

RSpec.describe ProviderInterface::SetupCompleteNextStepsComponent do
  let(:provider_user) { create(:provider_user) }
  let(:render) { render_inline(described_class.new(provider_user: provider_user)) }

  it 'shows a link to the applications page' do
    expect(render.css('a')[0].text).to eq('view applications')
    expect(render.css('a')[0].attributes['href'].value).to eq('/provider/applications')
  end

  context 'when the provider can manage users' do
    let(:provider_user) { create(:provider_user, :with_provider, :with_manage_users) }

    it 'shows a link to the users page' do
      expect(render.css('a')[1].text).to eq('invite or manage users')
      expect(render.css('a')[1].attributes['href'].value).to eq('/provider/account/users')
    end
  end

  context 'when the provider can not manage users' do
    it 'does not show a link to the users page' do
      expect(render.css('a').text).not_to include('invite or manage users')
    end
  end

  it 'shows a link to the notifications page' do
    expect(render.css('a').last.text).to eq('manage your email notifications')
    expect(render.css('a').last.attributes['href'].value).to eq('/provider/account/notification-settings')
  end
end
