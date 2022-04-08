require 'rails_helper'

RSpec.describe SupportInterface::ContactInformationComponent do
  let(:application_form) { build_stubbed(:completed_application_form) }

  subject(:result) { render_inline(described_class.new(application_form: application_form)) }

  it 'renders component with correct labels' do
    ['Phone number', 'Email address', 'Address'].each do |key|
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

  it 'shows change links' do
    expect(result.css('a').first.text).to eq('Change phone number')
  end

  context 'when the application form has a subsequent application' do
    let(:application_form) { create(:completed_application_form) }

    let!(:subsequent_application_form) { create(:application_form, previous_application_form: application_form) }

    it 'does not shows change links' do
      expect(result.css('a').text).not_to include('Change')
    end
  end
end
