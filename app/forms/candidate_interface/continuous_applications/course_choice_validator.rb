module CandidateInterface
  module ContinuousApplications
    class CourseChoiceValidator < ActiveModel::Validator
      def validate(record)
        return unless record.wizard.current_application
        return if record.wizard.edit?

        exists = record.wizard.current_application.application_choices.joins(:course_option).exists?(course_option: { course_id: record.course.id })

        if exists
          record.errors.add :base, 'You have already applied to this course'
        end
      end
    end
  end
end
