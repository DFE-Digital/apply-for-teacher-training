require 'rails_helper'

RSpec.describe PersonalDetailsComponent do
  let(:application_form) do
    build_stubbed(
      :completed_application_form,
      support_reference: 'AB123',
      date_of_birth: Date.new(2000, 1, 1),
      first_nationality: 'British',
      second_nationality: 'Irish',
      third_nationality: 'Spanish',
    )
  end

  subject(:result) { render_inline(PersonalDetailsComponent.new(application_form: application_form)) }

  it 'renders component with correct labels' do
    ['Reference', 'Full name', 'Date of birth', 'Nationality', 'Phone number', 'Email address', 'Address'].each do |key|
      expect(result.css('.govuk-summary-list__key').text).to include(key)
    end
  end

  it 'renders the candidate support reference' do
    expect(result.css('.govuk-summary-list__value').text).to include('AB123')
  end

  it 'renders the candidate name' do
    expect(result.css('.govuk-summary-list__value').text).to include("#{application_form.first_name} #{application_form.last_name}")
  end

  it 'renders the candidate date of birth' do
    expect(result.css('.govuk-summary-list__value').text).to include('1 January 2000')
  end

  it 'renders the candidates nationalities' do
    expect(result.css('.govuk-summary-list__value').text).to include('British, Irish, and Spanish')
  end

  it 'renders the candidate phone number' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.phone_number)
  end

  it 'renders the candidate email address' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.candidate.email_address)
  end

  it 'renders the candidate address and postcode' do
    full_address = [
      application_form.address_line1,
      application_form.address_line2,
      application_form.address_line3,
      application_form.address_line4,
      application_form.postcode,
    ].reject(&:blank?).join

    expect(result.css('.govuk-summary-list__value').text).to include(full_address)
  end
end
