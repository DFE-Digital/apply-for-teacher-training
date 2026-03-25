require 'rails_helper'

RSpec.describe ProviderInterface::ContactInformationComponent do
  before do
    allow(FeatureFlag).to receive(:active?)
      .with('2027_application_form_contact_details_residency_questions')
      .and_return(true)
  end

  let(:application_form) { build_stubbed(:completed_application_form, date_of_birth: Date.new(1991, 9, 9), country: 'GB-WLS', country_residency_since_birth: true, country_residency_date_from: Date.new(1991, 9, 9)) }

  subject(:result) { render_inline(described_class.new(application_form:)) }

  it 'renders component with correct labels' do
    ['Phone number', 'Email address', 'Address', 'Lived in Wales since'].each do |key|
      expect(result.css('.govuk-summary-list__key').text).to include(key)
    end
  end

  it 'renders the candidate phone number' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.phone_number)
  end

  it 'renders the candidate email address' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.candidate.email_address)
  end

  it 'renders the candidate address' do
    application_form.full_address.each do |address_line|
      expect(result.css('.govuk-summary-list__value').text).to include(address_line)
    end
  end

  it 'renders the residency start point' do
    expect(result.css('.govuk-summary-list__value').text).to include('Birth')
  end
end
