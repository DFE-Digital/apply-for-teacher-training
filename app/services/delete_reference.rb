class DeleteReference
  def call(reference:)
    raise 'Application has been sent to providers' if reference.application_form.submitted?

    if reference.selected
      reference.application_form.update!(references_completed: false)
    end
    reference.destroy!
  end
end
