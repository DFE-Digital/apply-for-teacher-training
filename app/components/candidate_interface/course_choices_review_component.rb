module CandidateInterface
  class CourseChoicesReviewComponent < ViewComponent::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(
      application_form:,
      editable: true,
      heading_level: 2,
      show_status: false,
      show_incomplete: false,
      missing_error: false,
      application_choice_error: false
    )
      @application_form = application_form
      @application_choices = @application_form.application_choices.includes(:course, :site, :provider, :offered_course_option).order(id: :asc)
      @editable = editable
      @heading_level = heading_level
      @show_status = show_status
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @application_choice_error = application_choice_error
    end

    def course_choice_rows(application_choice)
      rows = [
        course_row(application_choice),
        study_mode_row(application_choice),
        location_row(application_choice),
        type_row(application_choice.course),
        course_length_row(application_choice.course),
        start_date_row(application_choice.course),
      ].compact

      rows.tap do |r|
        r << status_row(application_choice) if @show_status
        r << rejection_reason_row(application_choice) if application_choice.rejection_reason.present?
        r << offer_withdrawal_reason_row(application_choice) if application_choice.offer_withdrawal_reason.present?
      end
    end

    def withdrawable?(application_choice)
      ApplicationStateChange.new(application_choice).can_withdraw?
    end

    def any_withdrawable?
      @application_form.application_choices.any? do |application_choice|
        withdrawable?(application_choice)
      end
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.course_choices_completed && @editable
    end

    def course_change_path(application_choice)
      if has_multiple_courses?(application_choice)
        candidate_interface_course_choices_course_path(
          application_choice.provider.id,
          course_choice_id: application_choice.id,
        )
      end
    end

    def site_change_path(application_choice)
      if has_multiple_sites?(application_choice)
        candidate_interface_course_choices_site_path(
          application_choice.provider.id,
          application_choice.course.id,
          application_choice.offered_option.study_mode,
          course_choice_id: application_choice.id,
        )
      end
    end

    def warning_container_css_class(application_choice)
      return unless FeatureFlag.active?('unavailable_course_option_warnings') && @editable

      if application_choice.course_option_availability_error?
        @application_choice_error ? 'app-review-warning app-review-warning--error' : 'app-review-warning'
      end
    end

  private

    attr_reader :application_form

    def course_row(application_choice)
      {
        key: 'Course',
        value: govuk_link_to("#{application_choice.offered_course.name} (#{application_choice.offered_course.code})", application_choice.offered_course.find_url, target: '_blank', rel: 'noopener'),
        action: "course choice for #{application_choice.course.name_and_code}",
        change_path: course_change_path(application_choice),
      }
    end

    def location_row(application_choice)
      {
        key: 'Location',
        value: "#{application_choice.offered_site.name}\n#{application_choice.offered_site.full_address}",
        action: "location for #{application_choice.course.name_and_code}",
        change_path: site_change_path(application_choice),
      }
    end

    def study_mode_row(application_choice)
      return unless application_choice.course.both_study_modes_available?

      change_path = candidate_interface_course_choices_study_mode_path(
        application_choice.provider.id,
        application_choice.course.id,
        course_choice_id: application_choice.id,
      )

      {
        key: 'Full time or part time',
        value: application_choice.offered_option.study_mode.humanize,
        action: "study mode for #{application_choice.course.name_and_code}",
        change_path: change_path,
      }
    end

    def type_row(course)
      {
        key: 'Type',
        value: course.description,
      }
    end

    def course_length_row(course)
      {
        key: 'Course length',
        value: DisplayCourseLength.call(course_length: course.course_length),
      }
    end

    def start_date_row(course)
      {
        key: 'Date course starts',
        value: course.start_date.strftime('%B %Y'),
      }
    end

    def status_row(application_choice)
      type =  case application_choice.status
              when 'awaiting_references', 'application_complete'
                :grey
              when 'awaiting_provider_decision'
                :purple
              when 'offer'
                :turquoise
              when 'rejected'
                :pink
              when 'pending_conditions'
                :blue
              when 'recruited'
                :green
              when 'declined', 'withdrawn', 'cancelled'
                :orange
              when 'conditions_not_met'
                :red
              end
      {
        key: 'Status',
        value: render(TagComponent.new(text: status_row_value(application_choice), type: type)),
      }
    end

    def status_row_value(application_choice)
      return t('candidate_application_states.offer_withdrawn') if application_choice.offer_withdrawn?

      t("candidate_application_states.#{application_choice.status}")
    end

    def rejection_reason_row(application_choice)
      {
        key: 'Reason for rejection',
        value: application_choice.rejection_reason,
      }
    end

    def offer_withdrawal_reason_row(application_choice)
      {
        key: 'Reason for offer withdrawal',
        value: application_choice.offer_withdrawal_reason,
      }
    end

    def has_multiple_sites?(application_choice)
      CourseOption.where(course_id: application_choice.course.id, study_mode: application_choice.offered_option.study_mode).many?
    end

    def has_multiple_courses?(application_choice)
      Course.current_cycle.where(provider: application_choice.provider).many?
    end
  end
end
