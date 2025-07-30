module CandidateInterface
  class FacInviteResponseForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :application_choice

    attribute :application_form
    attribute :invite
    attribute :apply_for_this_course, :string

    validates :apply_for_this_course, presence: true
    validate :cannot_already_have_an_open_application_to_course, if: :accepted_invite?

    def save
      return false if invalid?

      ActiveRecord::Base.transaction do
        course_option = CourseOption.find_by(course_id: invite.course_id)

        @application_choice = ApplicationChoice.create!(
          status: 'unsubmitted',
          current_course_option_id: course_option.id,
          course_option_id: course_option.id,
          application_form_id: application_form.id,
        )

        invite.update!(
          candidate_decision: 'applied',
          application_choice_id: @application_choice.id,
        )
      end
    end

    def accepted_invite?
      apply_for_this_course.to_s.strip.downcase == 'yes'
    end

  private

    def cannot_already_have_an_open_application_to_course
      return if application_form.blank? || invite.blank?

      open_application_exists = application_form.application_choices.any? do |choice|
        choice.course_option.course_id == invite.course_id &&
          ApplicationStateChange::UNSUCCESSFUL_STATES.exclude?(choice.status.to_sym)
      end

      if open_application_exists
        errors.add(:apply_for_this_course, :duplicate_course)
      end
    end
  end
end
