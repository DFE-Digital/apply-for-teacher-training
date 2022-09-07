require 'rails_helper'

RSpec.describe CandidateInterface::TrainingWithADisabilityReviewComponent do
  context 'when a candidate discloses a disability' do
    let(:application_form) do
      build_stubbed(
        :application_form,
        disclose_disability: true,
        disability_disclosure: 'I have difficulty climbing stairs',
      )
    end

    it 'renders component with correct values for a disclose_disability' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.training_with_a_disability.disclose_disability.label'))
      expect(result.css('.govuk-summary-list__value').text).to include('Yes')
      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_edit_training_with_a_disability_path)
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.training_with_a_disability.disclose_disability.change_action')}")
    end

    it 'renders component with correct values for an disability_disclosure' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.training_with_a_disability.disability_disclosure.review_label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('I have difficulty climbing stairs')
      expect(result.css('.govuk-summary-list__actions a')[1].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_edit_training_with_a_disability_path)
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.training_with_a_disability.disability_disclosure.change_action')}")
    end
  end

  context 'when a candidate does not disclose a disability' do
    let(:application_form) do
      build_stubbed(
        :application_form,
        disclose_disability: false,
        disability_disclosure: nil,
      )
    end

    it 'renders component with correct values for a disclose_disability' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__value').text).to include('No')
    end

    it 'renders component without disability disclosure' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).not_to include(t('application_form.training_with_a_disability.disability_disclosure.label'))
    end
  end

  context 'when disability disclosure is not editable' do
    let(:application_form) do
      build_stubbed(
        :application_form,
        disclose_disability: false,
        disability_disclosure: nil,
      )
    end

    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form:, editable: false))

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
    end
  end
end
