class CanAddMoreChoicesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    unless application_choice.application_form.can_submit_more_choices?
      record.errors.add(attribute, :max_course_choices, message: 'You cannot submit this application because you have already submitted the maximum number of applications')
    end

    if application_choice.application_form.unsuccessful_limit_reached?
      max_unsuccessful_attempts = [application_choice.application_form.unsuccessful_retry_limit, application_choice.application_form.in_progress_limit].max
      record.errors.add(
        attribute,
        :max_course_choices,
        message: "You cannot submit this application because you have #{max_unsuccessful_attempts} unsuccessful applications",
      )
    end
  end
end
