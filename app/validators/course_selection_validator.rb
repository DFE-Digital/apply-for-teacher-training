class CourseSelectionValidator < ActiveModel::Validator
  ALLOWED_REAPPLICATION_LIMIT = 2

  def validate(record)
    scope = scope_for_current_application(record)

    if reached_reapplication_limit?(scope, record)
      record.errors.add :base, :reached_reapplication_limit, message: 'You cannot apply to this training provider and course again'
      return
    end

    if exists_duplicate_application?(scope, record)
      record.errors.add :base, :duplicate_application_selection, message: 'You have already applied for this course'
    end
  end

  def scope_for_current_application(record)
    scope = record.wizard.current_application.application_choices.joins(:course_option)
    editing?(record) ? omit_current_application_choice(scope, record) : scope
  end

  def reached_reapplication_limit?(scope, record)
    scope.where(
      status: 'rejected',
      course_option: { course_id: record.course.id },
      current_recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
    ).count >= ALLOWED_REAPPLICATION_LIMIT
  end

  def exists_duplicate_application?(scope, record)
    scope.where({ status: ApplicationStateChange.non_reapply_states }).exists?(course_option: { course_id: record.course.id })
  end

  # Only validate against existing application choice that are not being edited
  def editing?(record)
    return false unless record.wizard.edit?

    course_id = record.wizard.application_choice.course.id

    course_id == record.course_id.to_i
  end

  def omit_current_application_choice(scope, record)
    scope.where.not({ id: record.wizard.application_choice.id })
  end
end
