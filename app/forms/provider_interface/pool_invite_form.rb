module ProviderInterface
  class PoolInviteForm
    include ActiveModel::Model

    attr_accessor :id, :course_id
    attr_reader :current_provider_user, :candidate

    validates :course_id, presence: true
    validate :course_is_open if -> { course.present? }
    validate :already_invited_to_course if -> { course.present? }

    def initialize(current_provider_user:, candidate: nil, pool_invite_form_params: {})
      @current_provider_user = current_provider_user
      @candidate = candidate
      super(pool_invite_form_params)
    end

    def self.build_from_invite(invite:, current_provider_user:)
      new(
        current_provider_user:,
        candidate: invite.candidate,
        pool_invite_form_params: {
          id: invite.id,
          course_id: invite.course_id,
        },
      )
    end

    def save
      if id.present?
        invite = Pool::Invite.find_by(
          id:,
          provider_id: current_provider_user.provider_ids,
        )

        invite.update!(course_id:)
        invite
      else
        Pool::Invite.create!(
          candidate: candidate,
          provider: course&.provider,
          course: course,
          invited_by: current_provider_user,
        )
      end
    end

    def available_courses
      @available_courses ||= current_provider_user.providers.map do |provider|
        GetAvailableCoursesForProvider.new(provider).call
      end.flatten
    end

    def course
      @course ||= Course.find_by(
        id: course_id,
        provider_id: current_provider_user.provider_ids,
      )
    end

  private

    def course_is_open
      errors.add(:course_id, :invalid) unless available_courses.include?(course)
    end

    def already_invited_to_course
      existing_invite = Pool::Invite.published.find_by(course_id:, candidate_id: candidate.id).present?
      errors.add(:course_id, :already_invited) if existing_invite
    end
  end
end
