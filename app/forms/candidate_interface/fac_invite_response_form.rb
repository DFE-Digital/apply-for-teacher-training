module CandidateInterface
  class FacInviteResponseForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :application_choice

    attribute :application_form
    attribute :invite
    attribute :apply_for_this_course, :string

    validates :apply_for_this_course, presence: true

    def save
      return false if invalid?

      course_option = CourseOption.find_by(course_id: invite.course_id)

      @application_choice = ApplicationChoice.create!(
        status: 'unsubmitted',
        current_course_option_id: course_option.id,
        course_option_id: course_option.id,
        application_form_id: application_form.id,
      )
    end

    def accepted_invite?
      apply_for_this_course.to_s.strip.downcase == 'yes'
    end
  end
end
