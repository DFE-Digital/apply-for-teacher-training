module CandidateInterface
  module ContinuousApplications
    # Validates that the course choice is not duplicated
    # Conditional exists to remove the course that is being edited from the checks for duplication
    class CourseSelectionValidator < ActiveModel::Validator
      def validate(record)
        return unless record.wizard.current_application

        scope = record.wizard.current_application.application_choices.joins(:course_option)
        scope = scope.where.not({ course_option: { course_id: record.course.id } }) if editing?(record)
        exists = scope.exists?(course_option: { course_id: record.course.id })

        if exists
          record.errors.add :base, 'You have already applied to this course'
        end
      end

      # Only validate against existing application choice that are not being edited
      def editing?(record)
        return false unless record.wizard.edit?

        choice_being_edited = record.wizard.application_choice

        choice_being_edited.course.id == record.course_id.to_i && choice_being_edited.course.provider_id == record.provider_id.to_i
      end
    end
  end
end
