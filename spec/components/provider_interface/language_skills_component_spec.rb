require 'rails_helper'

RSpec.describe ProviderInterface::LanguageSkillsComponent do
  it 'renders other languages spoken when english is the main language' do
    application_form = build_stubbed(
      :application_form,
      english_main_language: true,

      # english_language_details collects information about other languages spoken
      # FIXME: english_language_details and other_language_details are wrong way around in candidate form
      english_language_details: 'Details about other languages spoken',
    )

    result = render_inline(described_class, application_form: application_form)

    expect(result.css('.govuk-summary-list__key').text).to include('Is English your main language?')
    expect(result.css('.govuk-summary-list__value').text).to include('Yes')

    expect(result.css('.govuk-summary-list__key').text).to include('Other languages spoken')
    expect(result.css('.govuk-summary-list__value').text).to include('Details about other languages spoken')
  end

  it 'renders details about English when not the main language' do
    application_form = build_stubbed(
      :application_form,
      english_main_language: false,

      # other_language_details collects information and English skills
      # FIXME: english_language_details and other_language_details are wrong way around in candidate form
      other_language_details: 'Details about my English skills',
    )

    result = render_inline(described_class, application_form: application_form)

    expect(result.css('.govuk-summary-list__key').text).to include('Is English your main language?')
    expect(result.css('.govuk-summary-list__value').text).to include('No')

    expect(result.css('.govuk-summary-list__key').text).to include('English language qualifications and other languages spoken')
    expect(result.css('.govuk-summary-list__value').text).to include('Details about my English skills')
  end

  it 'indicates when an other language details has not been filled in' do
    application_form = build_stubbed(
      :application_form,
      english_main_language: false,
      other_language_details: '',
    )

    result = render_inline(described_class, application_form: application_form)
    expect(result.css('.govuk-summary-list__value').text).to include('No details given')
  end

  it 'indicates when english language details has not been filled in' do
    application_form = build_stubbed(
      :application_form,
      english_main_language: true,
      english_language_details: '',
    )

    result = render_inline(described_class, application_form: application_form)
    expect(result.css('.govuk-summary-list__value').text).to include('No details given')
  end
end
