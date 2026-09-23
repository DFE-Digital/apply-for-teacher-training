module SubsequentApplicationDeletable
private

  def delete_subsequent_application_form(application_form)
    subsequent_application_form = application_form.subsequent_application_form
    return if subsequent_application_form.blank? || subsequent_application_form.application_choices.present?

    application_form.subsequent_application_form.destroy!
  end
end
