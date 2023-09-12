class CanAddMoreChoicesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    unless application_choice.application_form.can_submit_further_applications?
      record.errors.add(attribute, :max_course_choices, message: 'You cannot submit this application because you have already submitted the maximum number of applications.')
    end
  end
end
