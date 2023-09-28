class OpenForApplicationsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return if application_choice.current_course.open_for_applications?

    record.errors.add(
      attribute,
      :not_open_for_applications,
      message: "You cannot submit this application now because the course has not opened. You will be able to submit it from #{application_choice.current_course.applications_open_from.to_fs(:govuk_date)}",
    )
  end
end
