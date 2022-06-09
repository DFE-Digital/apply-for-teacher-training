# frozen_string_literal: true

class CandidateInterface::SelectedReferencesComponent < ViewComponent::Base
  attr_reader :application_form, :selected_references, :editable, :show_incomplete, :is_errored

  def initialize(application_form, editable: true, show_incomplete: false, is_errored: false, return_to_application_review: false)
    @application_form = application_form
    @selected_references = application_form.selected_references
    @editable = editable
    @show_incomplete = show_incomplete
    @is_errored = is_errored
    @return_to_application_review = return_to_application_review
  end

  def show_incomplete_banner?
    !application_form.references_completed? && show_incomplete && editable
  end

  def rows
    [
      {
        key: 'Selected references',
        value: reference_values,
        bulleted_format: true,
        action: {
          href: candidate_interface_select_references_path(return_to_params),
          visually_hidden_text: 'selected references',
        },
        html_attributes: {
          data: {
            qa: 'selected-references',
          },
        },
      },
    ]
  end

  def reference_values
    selected_references.map do |reference|
      "#{reference.referee_type.capitalize.dasherize} reference from #{reference.name}"
    end
  end

  def incomplete_path
    if !application_form.minimum_references_available_for_selection?
      candidate_interface_references_review_path
    elsif !application_form.selected_enough_references?
      candidate_interface_select_references_path
    else
      candidate_interface_review_selected_references_path
    end
  end

  def incomplete_link_text
    if !application_form.minimum_references_available_for_selection?
      'You need to receive at least 2 references'
    elsif !application_form.selected_enough_references?
      'You need to select 2 references'
    else
      'Complete your references'
    end
  end

  def incomplete_message
    'References not marked as complete'
  end

private

  def return_to_params
    { 'return-to' => 'application-review' } if @return_to_application_review
  end
end
