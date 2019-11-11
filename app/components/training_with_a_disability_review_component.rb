class TrainingWithADisabilityReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @training_with_a_disability_form = CandidateInterface::TrainingWithADisabilityForm.build_from_application(
      @application_form,
    )
  end

  def training_with_a_disability_form_rows
    [disclose_disability_row, disability_disclosure_row]
  end

private

  attr_reader :application_form

  def disclose_disability_row
    {
      key: t('application_form.training_with_a_disability.disclose_disability.label'),
      value: boolean_display_value(@training_with_a_disability_form.disclose_disability),
      action: t('application_form.training_with_a_disability.disclose_disability.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_training_with_a_disability_edit_path,
    }
  end

  def disability_disclosure_row
    {
      key: t('application_form.training_with_a_disability.disability_disclosure.label'),
      value: @training_with_a_disability_form.disability_disclosure,
      action: t('application_form.training_with_a_disability.disability_disclosure.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_training_with_a_disability_edit_path,
    }
  end

  def boolean_display_value(value)
    key = if value.nil?
            'not_specified'
          elsif value
            'yes'
          else
            'no'
          end
    t(key, scope: %i[application_form training_with_a_disability disclose_disability])
  end
end
