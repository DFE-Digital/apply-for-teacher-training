module ProviderInterface
  class PoolInviteForm
    include ActiveModel::Model

    attr_accessor :id, :course_id
    attr_reader :current_provider_user, :candidate

    validates :course_id, presence: true
    validate :course_is_open if -> { course.present? }

    def initialize(current_provider_user:, candidate: nil, attributes: {})
      @current_provider_user = current_provider_user
      @candidate = candidate
      super(attributes)
    end

    def self.build_from_invite(invite:, current_provider_user:)
      new(
        current_provider_user:,
        candidate: invite.candidate,
        attributes: {
          id: invite.id,
          course_id: invite.course_id,
        },
      )
    end

    def persist!
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
  end
end
