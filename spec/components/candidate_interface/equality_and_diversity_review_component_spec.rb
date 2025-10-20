require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversityReviewComponent do
  let(:application_form) do
    build_stubbed(
      :application_form,
      equality_and_diversity: { 'sex' => 'male', 'disabilities' => [] },
    )
  end

  let(:application_form_with_free_school_meals) do
    build_stubbed(
      :application_form,
      equality_and_diversity:
      { 'sex' => 'male',
        'disabilities' => [],
        'ethnic_group' => 'Asian or Asian British',
        'ethnic_background' => 'Chinese',
        'free_school_meals' => 'yes' },
    )
  end

  context 'when there is a value for sex' do
    it 'displays the sex' do
      result = render_inline(described_class.new(application_form:))

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

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Disabilities or health conditions')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Blind<br role="presentation">Deaf<br role="presentation">Learning Difficulties')
    end
  end

  context 'when disabilities key is nil' do
    it 'displays other fields' do
      application_form.equality_and_diversity = { 'sex' => 'male' }

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Disabilities or health conditions')
      # Display other fields but an empty disabilities field
      expect(result.css('.govuk-summary-list__value').text).to eq('Male')
    end
  end

  context 'when disabilities are empty' do
    it 'displays "No"' do
      application_form.equality_and_diversity = { 'sex' => 'male', 'disabilities' => [] }

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Disabilities or health conditions')
      expect(result.css('.govuk-summary-list__value').text).to include('I do not have any of these disabilities or health conditions')
    end
  end

  context 'when there no disabilities' do
    it 'displays "No"' do
      application_form.equality_and_diversity = { 'sex' => 'male', 'disabilities' => [I18n.t('equality_and_diversity.disabilities.no.label')] }

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Disabilities or health conditions')
      expect(result.css('.govuk-summary-list__value').text).to include('I do not have any of these disabilities or health conditions')
    end
  end

  context 'when the disabilities has value Prefer not to say' do
    it 'displays "Prefer not to say"' do
      application_form.equality_and_diversity = { 'sex' => 'male', 'disabilities' => [I18n.t('equality_and_diversity.disabilities.opt_out.label')] }

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Disabilities or health conditions')
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

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Ethnicity')
      expect(result.css('.govuk-summary-list__value').text).to include('Chinese')
    end
  end

  context 'when the ethnic group is "Prefer not to say"' do
    it 'displays the ethnic group and ethnic background in brackets' do
      application_form.equality_and_diversity = {
        'sex' => 'male',
        'disabilities' => ['Blind', 'Deaf', 'Learning Difficulties'],
        'ethnic_group' => 'Prefer not to say',
      }

      result = render_inline(described_class.new(application_form:))

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

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Ethnicity')
      expect(result.css('.govuk-summary-list__value').text).to include('Asian or Asian British')
      expect(result.css('.govuk-summary-list__value').text).not_to include('(Prefer not to say)')
    end
  end

  context 'when there is a yes value for free school meals' do
    it 'displays the free school meal row' do
      application_form.equality_and_diversity.merge!({ 'free_school_meals' => 'yes' })
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Free school meals')
      expect(result.css('.govuk-summary-list__value').text).to include('I received free school meals at some point during my school years')
    end
  end

  context 'when there is a no value for free school meals' do
    it 'displays the free school meal row values' do
      application_form.equality_and_diversity.merge!({ 'free_school_meals' => 'no' })
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Free school meals')
      expect(result.css('.govuk-summary-list__value').text).to include('I did not receive free school meals at any point during my school years')
    end
  end

  context 'when there is a I do not know value for free school meals' do
    it 'displays the free school meal row values' do
      application_form.equality_and_diversity.merge!({ 'free_school_meals' => 'I do not know' })
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Free school meals')
      expect(result.css('.govuk-summary-list__value').text).to include('I do not know whether I received free school meals at any point during my school years')
    end
  end

  context 'when there is a Prefer not to say value for free school meals' do
    it 'displays the free school meal row values' do
      application_form.equality_and_diversity.merge!({ 'free_school_meals' => 'Prefer not to say' })
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Free school meals')
      expect(result.css('.govuk-summary-list__value').text).to include('Prefer not to say')
    end
  end

  context 'when editable' do
    it 'displays the change links' do
      result = render_inline(described_class.new(application_form: application_form_with_free_school_meals, editable: true))

      expect(result.text).to include('Change sex')
      expect(result.text).to include('Change disability')
      expect(result.text).to include('Change ethnicity')
      expect(result.text).to include('Change whether you ever got free school meals')
    end
  end

  context 'when not editable' do
    it 'does not display the change links' do
      result = render_inline(described_class.new(application_form: application_form_with_free_school_meals, editable: false))

      expect(result.text).not_to include('Change sex')
      expect(result.text).not_to include('Change disability')
      expect(result.text).not_to include('Change ethnicity')
      expect(result.text).not_to include('Change whether you ever got free school meals')
    end
  end
end
