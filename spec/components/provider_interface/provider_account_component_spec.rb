require 'rails_helper'

RSpec.describe ProviderInterface::ProviderAccountComponent do
  let(:provider1) { create(:provider) }
  let(:provider2) { create(:provider) }
  let(:current_provider_user) { create(:provider_user, providers: [provider1, provider2]) }

  subject(:result) { render_inline(described_class.new(current_provider_user: current_provider_user)) }

  it 'renders first name, last name and email address' do
    expect(result.css('.govuk-summary-list__key').text).to include('First name')
    expect(result.css('.govuk-summary-list__value').text).to include(current_provider_user.first_name)

    expect(result.css('.govuk-summary-list__key').text).to include('Last name')
    expect(result.css('.govuk-summary-list__value').text).to include(current_provider_user.last_name)

    expect(result.css('.govuk-summary-list__key').text).to include('Email address')
    expect(result.css('.govuk-summary-list__value').text).to include(current_provider_user.email_address)
  end

  it 'renders organisations user has access to' do
    expect(result.css('.govuk-summary-list__key').text).to include('Organisations you have access to')
    expect(result.css('.govuk-summary-list__value').text).to include(provider1.name, provider2.name)
  end

  it 'renders correct link to the DfE Sign-in profile page in qa' do
    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'qa' do
      expect(result.css('.govuk-link').attribute('href').value).to eq('https://test-profile.signin.education.gov.uk')
    end
  end

  it 'renders correct link to the DfE Sign-in profile page in non-qa environments' do
    expect(result.css('.govuk-link').attribute('href').value).to eq('https://profile.signin.education.gov.uk')
  end

  it 'renders permissions' do
    expect(result.css('.govuk-summary-list__key').text).to include('Permissions: ')
    expect(result.css('.govuk-summary-list__value').text).to include('The user can only view applications')
  end
end
