require 'rails_helper'

RSpec.describe SupportInterface::PersonalDetailsComponent do
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

  subject(:result) { render_inline(described_class.new(application_form: application_form)) }

  it 'renders component with correct labels' do
    ['First name', 'Last name', 'Date of birth', 'Nationality', 'Phone number', 'Email address', 'Address'].each do |key|
      expect(result.css('.govuk-summary-list__key').text).to include(key)
    end
  end

  it 'renders the candidate first name' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.first_name)
  end

  it 'renders the candidate last name' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.last_name)
  end

  it 'renders the candidate date of birth' do
    expect(result.css('.govuk-summary-list__value').text).to include('1 January 2000')
  end

  it 'renders the candidates nationalities' do
    expect(result.css('.govuk-summary-list__value').text).to include('British, Irish and Spanish')
  end

  it 'renders their HESA domicile code' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.domicile)
  end

  it 'renders the candidate phone number' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.phone_number)
  end

  it 'renders the candidate email address' do
    expect(result.css('.govuk-summary-list__value').text).to include(application_form.candidate.email_address)
  end

  it 'does not render right to work fields if nationality is British or Irish' do
    expect(result.text).not_to include('Has the right to work or study in the UK?')
    expect(result.text).not_to include('Immigration status')
  end

  it 'shows change links' do
    expect(result.css('a').first.text).to eq('Change first name')
  end

  context 'when the application form has a subsequent application' do
    let(:application_form) do
      create(
        :completed_application_form,
        support_reference: 'AB123',
        date_of_birth: Date.new(2000, 1, 1),
        first_nationality: 'British',
        second_nationality: 'Irish',
        third_nationality: 'Spanish',
      )
    end
    let!(:subsequent_application_form) { create(:application_form, previous_application_form: application_form) }

    it 'does not shows change links' do
      expect(result.css('a').text).not_to include('Change')
    end
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
      SupportInterface::PersonalDetailsComponent::RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES.each do |key, value|
        application_form.right_to_work_or_study = key
        result = render_inline(described_class.new(application_form: application_form))
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

      it 'renders the immigration status row' do
        expect(result.css('.govuk-summary-list__key').text).to include('Immigration status')
        expect(result.css('.govuk-summary-list__value').text).to include('I have settled status')
      end
    end

    context 'the right to work or study status is "no"' do
      before { application_form.right_to_work_or_study = 'no' }

      it 'does not render the immigration status row' do
        expect(result.css('.govuk-summary-list__key').text).not_to include('Immigration status')
      end
    end

    context 'the right to work or study status is "decide_later"' do
      before { application_form.right_to_work_or_study = 'decide_later' }

      it 'does not render the immigration status row' do
        expect(result.css('.govuk-summary-list__key').text).not_to include('Immigration status')
      end
    end
  end
end
