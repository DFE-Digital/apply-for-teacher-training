module FullSyncErrorHandler
  def raise_update_error(updates = {}, changeset = nil)
    return if updates.none?

    Sentry.capture_exception(TeacherTrainingPublicAPI::FullSyncUpdateError.new(error_message(updates, changeset)))
  end

private

  def error_message(updates, changeset)
    error_message = "#{updates.keys.to_sentence} have been updated"
    error_message << "\n#{stringify_changeset(changeset)}" if changeset.present?
    error_message
  end

  def stringify_changeset(changeset)
    changeset.map(&:to_s).join(",\n")
  end
end
