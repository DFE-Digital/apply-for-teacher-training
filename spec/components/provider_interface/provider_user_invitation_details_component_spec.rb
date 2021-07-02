require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserInvitationDetailsComponent do
  def setup
    @provider1 = create(:provider)
    @provider2 = create(:provider)
    @wizard = instance_double(
      ProviderInterface::ProviderUserInvitationWizard,
      first_name: 'Ed',
      last_name: 'Yewcator',
      email_address: 'ed@example.com',
      providers: [@provider1.id.to_s, @provider2.id.to_s],
      provider_permissions: {
        @provider1.id.to_s => { 'provider_id' => @provider1.id, 'permissions' => %w[manage_users] },
        @provider2.id.to_s => { 'provider_id' => @provider2.id, 'permissions' => %w[make_decisions] },
      },
      single_provider: nil,
    )
  end

  it 'renders basic details' do
    setup
    result = render_inline(described_class.new(wizard: @wizard))
    expect(result.css('.govuk-summary-list__key')[0].text).to include('First name')
    expect(result.css('.govuk-summary-list__value')[0].text).to include('Ed')
    expect(result.css('.govuk-summary-list__key')[1].text).to include('Last name')
    expect(result.css('.govuk-summary-list__value')[1].text).to include('Yewcator')
    expect(result.css('.govuk-summary-list__key')[2].text).to include('Email address')
    expect(result.css('.govuk-summary-list__value')[2].text).to include('ed@example.com')
  end

  it 'renders list of providers' do
    setup
    result = render_inline(described_class.new(wizard: @wizard))
    expect(result.css('.govuk-summary-list__key')[3].text).to include('Organisations this user will have access to')
    expect(result.css('.govuk-summary-list__value')[3].text).to include(@provider1.name)
    expect(result.css('.govuk-summary-list__value')[3].text).to include(@provider2.name)
  end

  it 'renders provider permissions' do
    setup
    result = render_inline(described_class.new(wizard: @wizard))
    expect(result.css('.govuk-summary-list__key')[4].text).to include("Permissions: #{@provider1.name}")
    expect(result.css('.govuk-summary-list__value')[4].text).to include('Manage users')
    expect(result.css('.govuk-summary-list__value')[4].text).not_to include('Make decisions')
    expect(result.css('.govuk-summary-list__key')[5].text).to include("Permissions: #{@provider2.name}")
    expect(result.css('.govuk-summary-list__value')[5].text).not_to include('Manage users')
    expect(result.css('.govuk-summary-list__value')[5].text).to include('Make decisions')
  end

  context 'when the wizard is for a single provider' do
    let(:provider) { create(:provider) }
    let(:wizard) do
      instance_double(
        ProviderInterface::ProviderUserInvitationWizard,
        first_name: 'Ed',
        last_name: 'Yewcator',
        email_address: 'ed@example.com',
        providers: [provider.id.to_s],
        provider_permissions: {
          provider.id.to_s => { 'provider_id' => provider.id, 'permissions' => %w[manage_users set_up_interviews] },
        },
        single_provider: 'true',
      )
    end

    context 'conditionally hides provider information' do
      it 'when the interview_permissions feature flag is on' do
        FeatureFlag.activate(:interview_permissions)

        result = render_inline(described_class.new(wizard: wizard))

        expect(result.css('.govuk-summary-list__key')[3].text).to include('Permissions')
        expect(result.css('.govuk-summary-list__key')[3].text).not_to include("Permissions: #{provider.name}")
        expect(result.css('.govuk-summary-list__value')[3].text).to include('Manage users')
        expect(result.css('.govuk-summary-list__value')[3].text).to include('Set up interviews')
      end

      it 'when the interview_permissions feature flag is off' do
        FeatureFlag.deactivate(:interview_permissions)

        result = render_inline(described_class.new(wizard: wizard))

        expect(result.css('.govuk-summary-list__key')[3].text).to include('Permissions')
        expect(result.css('.govuk-summary-list__key')[3].text).not_to include("Permissions: #{provider.name}")
        expect(result.css('.govuk-summary-list__value')[3].text).to include('Manage users')
        expect(result.css('.govuk-summary-list__value')[3].text).not_to include('Set up interviews')
      end
    end
  end

  context 'when no permissions are granted' do
    let(:provider) { create(:provider) }
    let(:wizard) do
      instance_double(
        ProviderInterface::ProviderUserInvitationWizard,
        first_name: 'Ed',
        last_name: 'Yewcator',
        email_address: 'ed@example.com',
        providers: [provider.id.to_s],
        provider_permissions: {
          provider.id.to_s => { 'provider_id' => provider.id },
        },
        single_provider: 'true',
      )
    end

    it 'presents the default view applications message' do
      result = render_inline(described_class.new(wizard: wizard))

      expect(result.css('.govuk-summary-list__value')[3].text).to include('The user will only be able to view applications')
    end
  end
end
