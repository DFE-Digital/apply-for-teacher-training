module CandidateInterface
  class TrainingWithADisabilityReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @training_with_a_disability_form = CandidateInterface::TrainingWithADisabilityForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def training_with_a_disability_form_rows
      [
        disclose_disability_row,
        (disability_disclosure_row if @training_with_a_disability_form.disclose_disability == 'yes'),
      ].compact
    end

    def show_missing_banner?
      !@application_form.training_with_a_disability_completed && @editable if @submitting_application
    end

  private

    attr_reader :application_form

    def disclose_disability_row
      {
        key: t('application_form.training_with_a_disability.disclose_disability.label'),
        value: boolean_display_value(@training_with_a_disability_form.disclose_disability),
        action: t('application_form.training_with_a_disability.disclose_disability.change_action'),
        change_path: candidate_interface_edit_training_with_a_disability_path(return_to_params),
        data_qa: 'adjustments-support-confirmation',
      }
    end

    def disability_disclosure_row
      {
        key: t('application_form.training_with_a_disability.disability_disclosure.review_label'),
        value: @training_with_a_disability_form.disability_disclosure,
        action: t('application_form.training_with_a_disability.disability_disclosure.change_action'),
        change_path: candidate_interface_edit_training_with_a_disability_path(return_to_params),
        data_qa: 'adjustments-support-details',
      }
    end

    def boolean_display_value(value)
      key = if value.nil?
              'not_specified'
            elsif value == 'yes'
              'yes'
            else
              'no'
            end
      t(key, scope: %i[application_form training_with_a_disability disclose_disability])
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
