class ApplicationsClosedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    apply_open = application_choice.application_form.can_submit?
    course_open = application_choice.current_course.open_for_applications?

    case [apply_open, course_open]
    in [true, true]
      return
    in [true, false]
      date = application_choice.course.applications_open_from.to_fs(:govuk_date)
    in [false, true]
      date = current_timetable.apply_reopens_at.to_fs(:govuk_date)
    in [false, false]
      date = [current_timetable.apply_opens_at, application_choice.course.applications_open_from].max.to_fs(:govuk_date)
    end

    record.errors.add(
      attribute,
      :applications_closed,
      date: date,
    )
  end

private

  def current_timetable
    @current_timetable = RecruitmentCycleTimetable.current_timetable
  end
end
