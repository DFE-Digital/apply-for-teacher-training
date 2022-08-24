module ReferencesPathHelper
  def references_type_path(referee_type:, reference_id:, application_choice: nil, step: nil)
    args = [referee_type, reference_id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_type_path", *args)
  end

  def reference_edit_type_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.referee_type, reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_edit_type_path", *args)
  end

  def references_name_path(referee_type:, reference_id:, application_choice: nil, step: nil)
    args = [referee_type, reference_id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_name_path", *args)
  end

  def reference_edit_name_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_edit_name_path", *args)
  end

  def references_email_address_path(reference:, application_choice: nil, step: nil)
    args = [reference.id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_email_address_path", *args)
  end

  def reference_edit_email_address_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_edit_email_address_path", *args)
  end

  def references_relationship_path(reference:, application_choice: nil, step: nil)
    args = [reference.id]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_relationship_path", *args)
  end

  def reference_edit_relationship_path(reference:, return_to:, application_choice: nil, step: nil)
    args = [reference.id, return_to]
    args.unshift(application_choice) if step == :accept_offer
    send(:"candidate_interface#{path_segment(step)}_new_references_edit_relationship_path", *args)
  end

  def path_segment(step)
    return if step.blank?

    "_#{step}"
  end

  def reference_workflow_step
    case request.path
    when /\/new-references\/accept-offer\//, /\/offer\/accept/
      :accept_offer
    when /\/new-references\/request-references\//
      :request_reference
    end
  end
end
