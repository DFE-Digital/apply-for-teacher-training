module ProviderInterface
  class PoolInviteForm
    include ActiveModel::Model
    include FreeTextInputHelper

    attr_accessor :id, :course_id, :course_id_raw, :return_to
    attr_reader :current_provider_user, :candidate
    alias_attribute :value, :course_id
    alias_attribute :raw_input, :course_id_raw

    validates :course_id, presence: true
    validate :no_free_text_input
    validate :course_is_open if -> { course.present? }
    validate :already_invited_to_course if -> { course.present? }
    validate :already_applied_to_course if -> { course.present? }

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
          # It is possible that the permissions have changed, so we need to look at all the connected providers,
          # not just the ones for which the user has permission to update
          provider_id: current_provider_user.providers.pluck(:id),
        )

        invite.update!(course:, provider: course.provider)
        invite
      else
        Pool::Invite.create!(
          candidate: candidate,
          application_form: candidate.current_application,
          provider: course&.provider,
          course: course,
          invited_by: current_provider_user,
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
        )
      end
    end

    def available_courses
      @available_courses ||= providers.map do |provider|
        GetAvailableCoursesForProvider.new(provider).open_courses
      end.flatten
    end

    def providers
      @providers ||= current_provider_user.providers_where_user_can_make_decisions
    end

    def course
      if instance_variable_defined?(:@course)
        @course
      else
        @course = Course.find_by(
          id: course_id,
          provider_id: current_provider_user.provider_ids,
        )
      end
    end

    def valid_options
      @valid_options ||= available_courses.map do |course|
        [
          current_provider_user.providers.many? ? course.name_code_and_course_provider : course.name_and_code,
          course.id,
        ]
      end.unshift([nil, nil])
    end

  private

    def course_is_open
      errors.add(:course_id, :invalid) unless available_courses.include?(course)
    end

    def already_invited_to_course
      existing_invite = Pool::Invite.published.find_by(course_id:, candidate_id: candidate.id).present?
      errors.add(:course_id, :already_invited) if existing_invite
    end

    def already_applied_to_course
      errors.add(:course_id, :already_applied) if course_id.to_i.in? candidate.current_application.already_applied_course_ids
    end

    def no_free_text_input
      errors.add(:course_id, :blank) if invalid_raw_data?
    end
  end
end
