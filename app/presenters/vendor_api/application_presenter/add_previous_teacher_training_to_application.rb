module VendorAPI::ApplicationPresenter::AddPreviousTeacherTrainingToApplication
  def schema
    return super unless previous_teacher_training_data

    super.deep_merge(
      attributes: {
        previous_teacher_training: previous_teacher_training_data,
      },
    )
  end

private

  def previous_teacher_training_data
    previous_itt = application_form.previous_teacher_trainings
                                 .where(status: 'published')
                                 .order(created_at: :desc)
                                 .first

    return nil unless previous_itt&.started

    {
      started: previous_itt.started,
      provider_name: previous_itt.provider_name,
      started_at: previous_itt.started_at&.iso8601,
      ended_at: previous_itt.ended_at&.iso8601,
      details: previous_itt.details,
    }
  end
end
