module CandidateInterface
  class CourseChoicesReviewComponent < ActionView::Component::Base
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
      {
        key: 'Course',
        value: "#{course_choice.course.name} (#{course_choice.course.code})",
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
                :secondary
              when 'awaiting_provider_decision'
                :primary
              when 'offer'
                :info_unfilled
              when 'rejected'
                :danger
              when 'withdrawn'
                :danger
              when 'pending_conditions'
                :info
              when 'declined'
                :warning
              else
                ''
              end
      {
        key: 'Status',
        value: render(TagComponent, text: t("candidate_application_states.#{course_choice.status}"), type: type),
      }
    end
  end
end
