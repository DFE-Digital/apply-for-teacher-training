module FullSyncErrorHandler
  def raise_update_error(updates = {})
    return if updates.none?

    Sentry.capture_exception(TeacherTrainingPublicAPI::FullSyncUpdateError.new("#{updates.keys.to_sentence} have been updated"))
  end
end
