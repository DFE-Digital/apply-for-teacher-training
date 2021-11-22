module SupportInterface
  class ChangeApplicationChoiceCourseOption
    attr_reader :application_choice, :provider_id, :course_code, :study_mode, :site_code, :audit_comment

    def initialize(application_choice_id:,
                   provider_id:,
                   course_code:,
                   study_mode:,
                   site_code:,
                   audit_comment:)
      @application_choice = ApplicationChoice.find(application_choice_id)
      @provider_id = provider_id
      @course_code = course_code
      @site_code = site_code
      @study_mode = study_mode
      @audit_comment = audit_comment
    end

    def call
      application_choice.update_course_option_and_associated_fields!(course_option,
                                                                     other_fields: { course_option: course_option },
                                                                     audit_comment: audit_comment)
    end

  private

    def course_option
      course.course_options.joins(:site).find_by!(site: { code: site_code }, study_mode: study_mode)
    end

    def course
      Course.find_by!(code: course_code,
                      provider_id: provider_id,
                      recruitment_cycle_year: RecruitmentCycle.current_year)
    end
  end
end
