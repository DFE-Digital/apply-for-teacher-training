class ChangeCourse
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option, :update_interviews_provider_service

  def initialize(actor:,
                 application_choice:,
                 course_option:,
                 update_interviews_provider_service:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @update_interviews_provider_service = update_interviews_provider_service
  end

  def save!
    auth.assert_can_make_decisions!(application_choice:, course_option:)

    old_course_option = application_choice.current_course_option

    if course.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          application_choice.update_course_option_and_associated_fields!(
            course_option,
            other_fields: {
              course_option:,
              course_changed_at: Time.zone.now,
            },
          )
          update_interviews_provider_service.save!
        end
        update_interviews_provider_service.notify

        if application_choice.pending_conditions?
          CandidateMailer.change_course_pending_conditions(
            application_choice,
            old_course_option,
          ).deliver_later
        else
          course_changed = course_option.course_id != old_course_option.course_id ||
                           course_option.study_mode != old_course_option.study_mode ||
                           course_option.course.qualifications.sort != old_course_option.course.qualifications.sort ||
                           (!application_choice.school_placement_auto_selected && course_option.site_id != old_course_option.site_id)

          if course_changed
            CandidateMailer.change_course(application_choice, old_course_option).deliver_later
          end
        end
      end
    else
      raise ValidationException, course.errors.map(&:message)
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor:)
  end

  def course
    @course ||= CourseValidations.new(application_choice:,
                                      course_option:)
  end
end
