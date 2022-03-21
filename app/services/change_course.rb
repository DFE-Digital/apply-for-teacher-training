class ChangeCourse
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option

  def initialize(actor:,
                 application_choice:,
                 course_option:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
  end

  def save!
    auth.assert_can_make_decisions!(application_choice: application_choice, course_option: course_option)

    if course.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          application_choice.update_course_option_and_associated_fields!(
            course_option,
            other_fields: { course_option: course_option },
          )
        end
      end
    else
      raise ValidationException, course.errors.map(&:message)
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor: actor)
  end

  def course
    @course ||= CourseValidations.new(application_choice: application_choice,
                                      course_option: course_option)
  end
end
