require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserPermissionsFormComponent do
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:form_model) { double }
  let(:provider) { provider_user.providers.first }
  let(:path) { '/path' }
  let(:user_name) { nil }
  let(:render) { render_inline(described_class.new(form_model: form_model, form_path: path, provider: provider, user_name: user_name)) }

  before do
    provider_permissions = provider_user.provider_permissions.first
    enabled_permissions = ProviderPermissions::VALID_PERMISSIONS.select { |p| provider_permissions.send(p) }
    allow(form_model).to receive(:permissions).and_return(enabled_permissions)
    allow(form_model).to receive(:model_name).and_return(ActiveModel::Name.new(Object))
  end

  it 'renders checkboxes for each of the user level permissions' do
    expected_permission_text = ProviderPermissions::VALID_PERMISSIONS.map { |permission| I18n.t("user_permissions.#{permission}.description") }
    expect(render.css('.govuk-checkboxes__item').map(&:text)).to eq(expected_permission_text)
  end

  it 'uses the given path for the form' do
    expect(render.css('form').first.attributes['action'].value).to eq(path)
  end

  context 'when the provider has no partner organisations' do
    before { allow(ProviderInterface::ProviderPartnerPermissionBreakdownComponent).to receive(:new).and_call_original }

    it 'does not render the organisation permissions explanation text' do
      expect(render.css('p').text).not_to include('User permissions for courses you work on with partner organisations are affected by organisation permissions')
      expect(render.css('p').text).not_to include('This means that the permissions you give to users may only apply to courses you work on with certain partner organisations.')
    end

    it 'does not render the details component' do
      expect(render.css('details')).to be_empty
      expect(ProviderInterface::ProviderPartnerPermissionBreakdownComponent).not_to have_received(:new)
    end

    it 'renders the correct legend as an h1 for the form' do
      expect(render.css('legend > h1').text).to include('User permissions')
      expect(render.text).not_to include('Choose user permissions')
    end

    it 'renders the correct caption as a span within a legend for the form' do
      expect(render.css('legend > h1 > span').text).to include("Invite user - #{provider.name}")
    end
  end

  context 'when the provider has partner organisations' do
    before do
      relationship = create(:provider_relationship_permissions, training_provider: provider)
      create(:course, :open_on_apply, provider: provider, accredited_provider: relationship.ratifying_provider)

      allow(ProviderInterface::ProviderPartnerPermissionBreakdownComponent).to receive(:new).with(provider: provider, permission: anything).and_call_original
    end

    it 'renders the organisation permissions explanation text' do
      expect(render.css('p').text).to include('User permissions for courses you work on with partner organisations are affected by organisation permissions')
      expect(render.css('p').text).to include('This means that the permissions you give to users may only apply to courses you work on with certain partner organisations.')
    end

    it 'renders the details component' do
      expect(render.css('details > summary').text.squish).to eq('Check how user permissions are affected by organisation permissions')
      expect(render.css('details h2').map(&:text)).to contain_exactly(
        'Make offers and reject applications',
        'View criminal convictions and professional misconduct',
        'View sex, disability and ethnicity information',
      )

      expect(ProviderInterface::ProviderPartnerPermissionBreakdownComponent).to have_received(:new).thrice
    end

    it 'renders the correct legend for the form' do
      expect(render.css('legend').text).to include('Choose user permissions')
    end

    it 'renders the correct caption as a span for the form' do
      expect(render.css('h1 > span').text).to include("Invite user - #{provider.name}")
    end
  end

  context 'when a username is passed in' do
    let(:user_name) { Faker::Name.name }

    it 'shows the user name in the caption' do
      expect(render.css('h1 > span').text).to include(user_name)
    end
  end
end
