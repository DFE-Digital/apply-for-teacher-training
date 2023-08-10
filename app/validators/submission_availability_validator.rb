class SubmissionAvailabilityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return if application_choice.unsubmitted?

    record.errors.add(attribute, :application_already_submitted)
  end
end
