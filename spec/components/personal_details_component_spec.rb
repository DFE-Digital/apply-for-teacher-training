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
    expect(result.css('.govuk-summary-list__value').text).to include('British, Irish and Spanish')
  end

  it 'renders the candidate phone number' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.phone_number)
  end

  it 'renders the candidate email address' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.candidate.email_address)
  end

  it 'renders the candidate address and postcode for uk addresses' do
    full_address = [
      application_form.address_line1,
      application_form.address_line2,
      application_form.address_line3,
      application_form.address_line4,
      application_form.postcode,
    ].reject(&:blank?).join

    expect(result.css('.govuk-summary-list__value').text).to include(full_address)
  end

  it 'renders the candidate address and postcode for international addresses' do
    application_form = build_stubbed(:completed_application_form, :international_address)

    international_address = [
      application_form.international_address,
      COUNTRIES[application_form.country],
    ].reject(&:blank?).join

    result = render_inline(PersonalDetailsComponent.new(application_form: application_form))

    expect(result.css('.govuk-summary-list__value').text).to include(international_address)
  end

  it 'does not render right to work fields if nationality is British or Irish' do
    expect(result.text).not_to include('Has the right to work or study in the UK?')
    expect(result.text).not_to include('Residency details')
  end

  context 'a candidate whose nationality is neither British or Irish' do
    let(:application_form) do
      build_stubbed(
        :completed_application_form,
        first_nationality: 'Pakistani',
        second_nationality: 'Singaporean',
        third_nationality: 'Spanish',
      )
    end

    it 'renders their right to work or study status' do
      PersonalDetailsComponent::RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES.each do |key, value|
        application_form.right_to_work_or_study = key
        result = render_inline(PersonalDetailsComponent.new(application_form: application_form))
        row_title = result.css('.govuk-summary-list__row')[5].css('dt').text
        row_value = result.css('.govuk-summary-list__row')[5].css('dd').text
        expect(row_title).to include 'Has the right to work or study in the UK?'
        expect(row_value).to include value
      end
    end

    context 'the right to work or study status is "yes"' do
      before do
        application_form.right_to_work_or_study = 'yes'
        application_form.right_to_work_or_study_details = 'I have settled status'
      end

      it 'renders the residency_details_row' do
        expect(result.css('.govuk-summary-list__key').text).to include('Residency details')
        expect(result.css('.govuk-summary-list__value').text).to include('I have settled status')
      end
    end

    context 'the right to work or study status is "no"' do
      before { application_form.right_to_work_or_study = 'no' }

      it 'does not render the residency_details_row' do
        expect(result.css('.govuk-summary-list__key').text).not_to include('Residency details')
      end
    end

    context 'the right to work or study status is "decide_later"' do
      before { application_form.right_to_work_or_study = 'decide_later' }

      it 'does not render the residency_details_row' do
        expect(result.css('.govuk-summary-list__key').text).not_to include('Residency details')
      end
    end
  end
end
