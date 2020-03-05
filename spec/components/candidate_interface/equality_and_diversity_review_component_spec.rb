require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversityReviewComponent do
  let(:application_form) do
    build_stubbed(
      :application_form,
      equality_and_diversity: { 'sex' => 'male', 'disabilities' => [] },
    )
  end

  context 'when there is a value for sex' do
    it 'displays the sex' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Sex')
      expect(result.css('.govuk-summary-list__value').text).to include('Male')
    end
  end

  context 'when there are disabilities' do
    it 'displays "Yes" and the disabilities in brackets' do
      application_form.equality_and_diversity = {
        'sex' => 'male',
        'disabilities' => ['Blind', 'Deaf', 'Learning Difficulties'],
        'ethnic_group' => 'Asian or Asian British',
        'ethnic_background' => 'Chinese',
      }

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Disability')
      expect(result.css('.govuk-summary-list__value').text).to include('Yes (Blind, Deaf and Learning Difficulties)')
    end
  end

  context 'when there no disabilities' do
    it 'displays "No"' do
      application_form.equality_and_diversity = { 'sex' => 'male', 'disabilities' => [] }

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Disability')
      expect(result.css('.govuk-summary-list__value').text).to include('No')
    end
  end

  context 'when the disabilities has value Prefer not to say' do
    it 'displays "Prefer not to say"' do
      application_form.equality_and_diversity = { 'sex' => 'male', 'disabilities' => ['Prefer not to say'] }

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Disability')
      expect(result.css('.govuk-summary-list__value').text).to include('Prefer not to say')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Yes')
    end
  end

  context 'when there are values for ethnic group and ethnic background' do
    it 'displays the ethnic group and ethnic background in brackets' do
      application_form.equality_and_diversity = {
        'sex' => 'male',
        'disabilities' => ['Blind', 'Deaf', 'Learning Difficulties'],
        'ethnic_group' => 'Asian or Asian British',
        'ethnic_background' => 'Chinese',
      }

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Ethnicity')
      expect(result.css('.govuk-summary-list__value').text).to include('Asian or Asian British (Chinese)')
    end
  end

  context 'when the ethnic group is "Prefer not to say"' do
    it 'displays the ethnic group and ethnic background in brackets' do
      application_form.equality_and_diversity = {
        'sex' => 'male',
        'disabilities' => ['Blind', 'Deaf', 'Learning Difficulties'],
        'ethnic_group' => 'Prefer not to say',
      }

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Ethnicity')
      expect(result.css('.govuk-summary-list__value').text).to include('Prefer not to say')
      expect(result.css('.govuk-summary-list__value').text).not_to include('()')
    end
  end

  context 'when there is a value for ethnic group but ethnic background is "Prefer not to say"' do
    it 'displays the ethnic group and ethnic background in brackets' do
      application_form.equality_and_diversity = {
        'sex' => 'male',
        'disabilities' => ['Blind', 'Deaf', 'Learning Difficulties'],
        'ethnic_group' => 'Asian or Asian British',
        'ethnic_background' => 'Prefer not to say',
      }

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Ethnicity')
      expect(result.css('.govuk-summary-list__value').text).to include('Asian or Asian British')
      expect(result.css('.govuk-summary-list__value').text).not_to include('(Prefer not to say)')
    end
  end

  context 'when editable' do
    it 'displays the change links' do
      result = render_inline(described_class.new(application_form: application_form, editable: true))

      expect(result.text).to include('Change sex')
      expect(result.text).to include('Change disability')
      expect(result.text).to include('Change ethnicity')
    end
  end

  context 'when not editable' do
    it 'does not display the change links' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.text).not_to include('Change sex')
      expect(result.text).not_to include('Change disability')
      expect(result.text).not_to include('Change ethnicity')
    end
  end
end
