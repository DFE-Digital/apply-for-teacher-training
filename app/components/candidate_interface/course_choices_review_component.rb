module CandidateInterface
  class CourseChoicesReviewComponent < ActionView::Component::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_status: false, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @course_choices = @application_form.application_choices.includes(:course, :site, :provider, :offered_course_option).order(id: :asc)
      @editable = editable
      @heading_level = heading_level
      @show_status = show_status
      @show_incomplete = show_incomplete
      @missing_error = missing_error
    end

    def course_choice_rows(course_choice)
      rows =   [
                 course_row(course_choice),
                 study_mode_row(course_choice),
                 location_row(course_choice),
                 type_row(course_choice.course),
                 course_length_row(course_choice.course),
                 start_date_row(course_choice.course),
               ].compact

      rows.tap do |r|
        r << status_row(course_choice) if @show_status
        r << rejection_reason_row(course_choice) if course_choice.rejection_reason.present?
        r << offer_withdrawal_reason_row(course_choice) if course_choice.offer_withdrawal_reason.present?
      end
    end

    def withdrawable?(course_choice)
      ApplicationStateChange.new(course_choice).can_withdraw?
    end

    def any_withdrawable?
      @application_form.application_choices.any? do |course_choice|
        withdrawable?(course_choice)
      end
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.course_choices_completed && @editable
    end

  private

    attr_reader :application_form

    def course_row(course_choice)
      change_path = if FeatureFlag.active?('edit_course_choices') && has_multiple_courses?(course_choice)
                      candidate_interface_course_choices_course_path(
                        course_choice.provider.id,
                        course_choice_id: course_choice.id,
                      )
                    end

      {
        key: 'Course',
        value: govuk_link_to("#{course_choice.offered_course.name} (#{course_choice.offered_course.code})", course_choice.offered_course.find_url, target: '_blank', rel: 'noopener'),
        action: "course choice for #{course_choice.course.name_and_code}",
        change_path: change_path,
      }
    end

    def location_row(course_choice)
      change_path = if FeatureFlag.active?('edit_course_choices') && has_multiple_sites?(course_choice)
                      candidate_interface_course_choices_site_path(
                        course_choice.provider.id,
                        course_choice.course.id,
                        course_choice.offered_option.study_mode,
                        course_choice_id: course_choice.id,
                      )
                    end

      {
        key: 'Location',
        value: "#{course_choice.offered_site.name}\n#{course_choice.offered_site.full_address}",
        action: "location for #{course_choice.course.name_and_code}",
        change_path: change_path,
      }
    end

    def study_mode_row(course_choice)
      return unless course_choice.course.both_study_modes_available?

      change_path = if FeatureFlag.active?('edit_course_choices')
                      candidate_interface_course_choices_study_mode_path(
                        course_choice.provider.id,
                        course_choice.course.id,
                        course_choice_id: course_choice.id,
                      )
                    end

      {
        key: 'Full time or part time',
        value: course_choice.offered_option.study_mode.humanize,
        action: "study mode for #{course_choice.course.name_and_code}",
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

    def status_row(course_choice)
      type =  case course_choice.status
              when 'awaiting_references', 'application_complete'
                :grey
              when 'awaiting_provider_decision'
                :blue
              when 'offer'
                :green
              when 'rejected', 'withdrawn'
                :red
              when 'pending_conditions'
                :turquoise
              when 'declined'
                :orange
              end
      {
        key: 'Status',
        value: render(TagComponent.new(text: status_row_value(course_choice), type: type)),
      }
    end

    def status_row_value(course_choice)
      return t('candidate_application_states.offer_withdrawn') if course_choice.offer_withdrawn?

      t("candidate_application_states.#{course_choice.status}")
    end

    def rejection_reason_row(course_choice)
      {
        key: 'Reason for rejection',
        value: course_choice.rejection_reason,
      }
    end

    def offer_withdrawal_reason_row(course_choice)
      {
        key: 'Reason for offer withdrawal',
        value: course_choice.offer_withdrawal_reason,
      }
    end

    def has_multiple_sites?(course_choice)
      CourseOption.where(course_id: course_choice.course.id, study_mode: course_choice.offered_option.study_mode).many?
    end

    def has_multiple_courses?(course_choice)
      Course.where(provider: course_choice.provider).many?
    end
  end
end
