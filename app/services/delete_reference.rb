class DeleteReference
  def call(reference:)
    raise 'Application has been sent to providers' if reference.application_form.submitted? && reference.complete_contact_details?
    raise 'Reference cannot be deleted because it is from a previous application' if reference.duplicate?

    if reference.selected
      reference.application_form.update!(references_completed: false)
    end
    reference.destroy!
  end
end
