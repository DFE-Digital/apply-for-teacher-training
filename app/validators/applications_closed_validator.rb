class ApplicationsClosedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    unless application_choice.application_form.can_submit? # Current cycle, between apply opens and apply deadline
      record.errors.add(
        attribute,
        :applications_closed,
        date: current_timetable.apply_reopens_at.to_fs(:govuk_date),
      )
    end
  end

private

  def current_timetable
    @current_timetable = RecruitmentCycleTimetable.current_timetable
  end
end
