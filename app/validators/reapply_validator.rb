class ReapplyValidator < ActiveModel::Validator
  def validate(record)
    @record = record

    # Do not validate if the record is in a reapliable status
    return true if ApplicationStateChange::REAPPLY_STATUSES.include?(record.status.to_s.to_sym)

    # Skip validation if the application is blank - other validations cover this
    return unless record.application_form_id.present? || record.course_option_id.present?

    # get all the application choices for the current application
    scope = record.application_form.application_choices.joins(:course_option)

    # restrict to non-reapply statuses
    scope = restrict_to_reapply_statuses(scope)

    # if updating, remove the course that is being edited from the checks for duplication
    scope = omit_current_application_choice(scope) if updating?

    # check if the course already exists
    exists = scope.exists?(course_option: { course_id: record.course_option.course_id })

    if exists
      @record.errors.add :base, 'cannot apply to the same course when an open application exists'
    end
  end

  # Only validate against existing application choice that are not being edited
  def updating?
    @record.persisted?
  end

  def omit_current_application_choice(scope)
    scope.where.not({ id: @record.id })
  end

  def restrict_to_reapply_statuses(scope)
    scope.where({ status: ApplicationStateChange::NON_REAPPLY_STATUSES })
  end

  def current_application
    @record.wizard.current_application
  end
end
