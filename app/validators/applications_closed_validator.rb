class ApplicationsClosedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    apply_open = CycleTimetable.can_submit?(application_choice.application_form)
    course_open = application_choice.current_course.past_open_date?

    case [apply_open, course_open]
    in [true, true]
      return
    in [true, false]
      date = application_choice.course.applications_open_from.to_fs(:govuk_date)
    in [false, true]
      date = CycleTimetable.apply_opens.to_fs(:govuk_date)
    in [false, false]
      date = [CycleTimetable.apply_opens, application_choice.course.applications_open_from].max.to_fs(:govuk_date)
    end

    record.errors.add(
      attribute,
      :applications_closed,
      date: date,
    )
  end
end
