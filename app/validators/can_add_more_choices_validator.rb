class CanAddMoreChoicesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    unless application_choice.application_form.can_submit_further_applications?
      record.errors.add(attribute, :max_course_choices, message: 'You cannot submit this application because you have already submitted the maximum number of applications')
    end

    if application_choice.application_form.reached_maximum_unsuccessful_choices?
      record.errors.add(attribute, :max_course_choices, message: "You cannot submit this application because you have #{ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS} unsuccessful applications")
    end
  end
end
