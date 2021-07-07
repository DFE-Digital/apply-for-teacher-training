require 'rails_helper'

RSpec.describe ProviderInterface::DsaSuccessPageComponent do
  let(:feature_flag_state) { :on }
  let(:provider_user) { create(:provider_user) }
  let(:render) { render_inline(described_class.new(provider_user: provider_user, provider_permission_setup_pending: permissions_require_setup)) }

  before do
    if feature_flag_state == :on
      FeatureFlag.activate(:accredited_provider_setting_permissions)
    else
      FeatureFlag.deactivate(:accredited_provider_setting_permissions)
    end
  end

  context 'when there are permissions to set up' do
    let(:permissions_require_setup) { true }

    it 'shows a continue button' do
      expect(render.css('a').text).to eq('Continue')
    end

    it 'renders the correct text' do
      expect(render.css('p').first.text.squish).to eq('Either you or your partner organisations must set up organisation permissions before you can manage teacher training applications.')
    end
  end

  context 'when permissions have been set up' do
    let(:permissions_require_setup) { false }

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

  context 'when the feature flag is off' do
    let(:feature_flag_state) { :off }

    context 'when there are permissions to set up' do
      let(:permissions_require_setup) { true }

      it 'shows a set up permissions button' do
        expect(render.css('a').text).to eq('Set up permissions')
      end

      it 'renders the correct text' do
        expect(render.css('p').first.text.squish).to eq('You need to set up permissions for your organisation before you do anything else. We’ll guide you through this process.')
      end
    end

    context 'when permissions have been set up' do
      let(:permissions_require_setup) { false }

      it 'shows a link to the applications page' do
        expect(render.css('a').last.text).to eq('Continue')
        expect(render.css('a').last.attributes['href'].value).to eq('/provider/applications')
      end

      context 'when the provider can manage users' do
        let(:provider_user) { create(:provider_user, :with_provider, :with_manage_users) }

        it 'shows a link to the users page' do
          expect(render.css('a').first.text).to eq('Users')
          expect(render.css('a').first.attributes['href'].value).to eq('/provider/account/users')
        end
      end

      context 'when the provider can not manage users' do
        it 'does not show a link to the users page' do
          expect(render.css('a').text).not_to include('Users')
        end
      end
    end
  end
end
