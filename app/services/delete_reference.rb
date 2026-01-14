class DeleteReference
  def call(reference:)
    raise 'Reference feedback has been requested' unless reference.not_requested_yet?

    if reference.selected
      reference.application_form.update!(references_completed: false)
    end
    reference.destroy!
  end
end
