module ReferencesPathHelper
  def references_type_path(referee_type:, reference_id:, return_to: nil, application_choice: nil, step: nil)
    args = [referee_type, reference_id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_type_path", *args)
  end

  alias name_previous_path references_type_path

  def reference_edit_type_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.referee_type, reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    args.shift if reference.referee_type.blank?
    blank_type = reference.referee_type.blank? ? '_blank' : ''
    send(:"candidate_interface#{path_segment(step)}_references_edit#{blank_type}_type_path", *args)
  end

  def references_name_path(referee_type:, reference_id:, application_choice: nil, step: nil)
    args = [referee_type, reference_id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_name_path", *args)
  end

  alias email_address_previous_path references_name_path

  def reference_edit_name_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_edit_name_path", *args)
  end

  def references_email_address_path(reference:, application_choice: nil, step: nil)
    args = [reference.id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_email_address_path", *args)
  end

  alias relationship_previous_path references_email_address_path

  def reference_edit_email_address_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_edit_email_address_path", *args)
  end

  def references_relationship_path(reference:, application_choice: nil, step: nil)
    args = [reference.id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_relationship_path", *args)
  end

  def reference_edit_relationship_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_references_edit_relationship_path", *args)
  end

  def type_previous_path(application_choice: nil, step: nil)
    if step == :accept_offer
      candidate_interface_accept_offer_path(application_choice)
    else
      send(:"candidate_interface#{path_segment(step)}_references_start_path")
    end
  end

  def path_segment(step)
    return if step.blank?

    "_#{step}"
  end

  def reference_workflow_step
    case request.path
    when /\/references\/accept-offer\//, /\/offer\/accept/
      :accept_offer
    when /\/references\/request-references\//
      :request_reference
    end
  end
end
