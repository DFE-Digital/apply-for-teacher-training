class CycleVerificationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _application_choice)
    return if CycleTimetable.can_submit?(record.application_form)

    record.errors.add(
      attribute,
      :can_not_submit_this_time_in_the_cycle,
      message: "You cannot submit this application now. You will be able to submit it from #{CycleTimetable.apply_opens.to_fs(:govuk_date_and_time)}",
    )
  end
end
