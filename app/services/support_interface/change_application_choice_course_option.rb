module SupportInterface
  class ApplicationStateError < StandardError; end

  class ChangeApplicationChoiceCourseOption
    VALID_STATES = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER

    attr_reader :application_choice, :provider_id, :course_code, :study_mode, :site_code, :audit_comment, :recruitment_cycle_year
    attr_accessor :confirm_course_change

    def initialize(application_choice_id:,
                   provider_id:,
                   course_code:,
                   study_mode:,
                   site_code:,
                   audit_comment:,
                   confirm_course_change: false,
                   recruitment_cycle_year: RecruitmentCycle.current_year)
      @application_choice = ApplicationChoice.find(application_choice_id)
      @provider_id = provider_id
      @course_code = course_code
      @site_code = site_code
      @study_mode = study_mode
      @audit_comment = audit_comment
      @confirm_course_change = confirm_course_change
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      check_application_state!
      check_interviewing_providers!
      check_course_full!

      application_choice.update_course_option_and_associated_fields!(course_option, other_fields:, audit_comment:)
    end

  private

    def check_application_state!
      return if confirm_course_change.present?
      return if VALID_STATES.include?(application_choice.status.to_sym)

      raise ApplicationStateError, "Changing the course option of application choices in the #{application_choice.status} state is not allowed"
    end

    def check_interviewing_providers!
      return if confirm_course_change.present?
      return if !application_choice.interviewing? || (application_choice.interviewing? && application_choice.provider_ids.include?(provider_id))

      raise ProviderInterviewError, 'Changing a course choice when the provider is not on the interview is not allowed'
    end

    def check_course_full!
      return if confirm_course_change.present?
      return if course_option.vacancy_status == 'vacancies'

      raise CourseFullError, I18n.t('support_interface.errors.messages.course_full_error')
    end

    def course_option
      course.course_options.joins(:site).find_by!(site: { code: site_code }, study_mode:)
    end

    def course
      Course.find_by!(code: course_code,
                      provider_id:,
                      recruitment_cycle_year: recruitment_cycle_year)
    end

    def other_fields
      return { course_option: } if VALID_STATES.include?(application_choice.status.to_sym)

      {}
    end
  end
end
