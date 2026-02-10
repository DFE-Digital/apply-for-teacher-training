module VendorAPI::ApplicationPresenter::AddPossibleUndeclaredPreviousTeacherTrainingUrl
  def schema
    super.deep_merge!({
      attributes: {
        possible_undeclared_previous_teacher_training_details_url:,
      },
    })
  end

  def possible_undeclared_previous_teacher_training_details_url
    possible_previous_teacher_trainings? ? provider_interface_application_choice_url(application_choice, anchor: 'previous_teacher_trainings') : nil
  end

  def possible_previous_teacher_trainings?
    application_choice.candidate.possible_previous_teacher_trainings.any?
  end
end
