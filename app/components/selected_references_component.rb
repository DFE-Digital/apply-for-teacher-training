# frozen_string_literal: true

class SelectedReferencesComponent < ViewComponent::Base
  attr_reader :application_form, :selected_references, :editable, :is_errored

  def initialize(application_form, editable: true, is_errored: false)
    @application_form = application_form
    @selected_references = application_form.selected_references
    @editable = editable
    @is_errored = is_errored
  end

  def rows
    [
      {
        key: 'Selected references',
        value: reference_values,
        action: 'Change selected references',
        change_path: candidate_interface_select_references_path,
      },
    ]
  end

  # TODO: refactor the following, possibly by enhancing SummaryCardComponent to
  # support rendering of bulleted lists
  def reference_values
    list = '<ul class="govuk-list govuk-list--bullet">'.html_safe
    selected_references.map do |reference|
      list << '<li>'.html_safe << "#{reference.referee_type.humanize} reference from #{reference.name}" << '</li>'.html_safe
    end
    list + '</ul>'.html_safe
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
end
