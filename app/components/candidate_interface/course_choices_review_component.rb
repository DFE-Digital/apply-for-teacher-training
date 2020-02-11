module CandidateInterface
  class CourseChoicesReviewComponent < ActionView::Component::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_status: false, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @course_choices = @application_form.application_choices.includes(:course, :site, :provider).order(id: :asc)
      @editable = editable
      @heading_level = heading_level
      @show_status = show_status
      @show_incomplete = show_incomplete
      @missing_error = missing_error
    end

    def course_choice_rows(course_choice)
      [
        course_row(course_choice),
        location_row(course_choice),
      ].tap do |r|
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
      url = "https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{course_choice.provider.code}/#{course_choice.course.code}"

      {
        key: 'Course',
        value: govuk_link_to("#{course_choice.course.name} (#{course_choice.course.code})", url, target: '_blank', rel: 'noopener'),
      }
    end

    def location_row(course_choice)
      {
        key: 'Location',
        value: "#{course_choice.site.name}\n#{course_choice.site.full_address}",
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
        value: render(TagComponent, text: status_row_value(course_choice), type: type),
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
  end
end
