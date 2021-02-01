module CandidateInterface
  class RestructuredWorkHistoryReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @work_history_with_breaks = WorkHistoryWithBreaks.new(@application_form).timeline
    end

    def show_missing_banner?
      @show_incomplete
    end

    def no_work_experience_rows
      [
        {
          key: t('application_form.work_history.explanation.review_label'),
          value: no_work_experience_value,
          action: t('application_form.work_history.explanation.change_action'),
          change_path: candidate_interface_restructured_work_history_path,
        },
      ]
    end

  private

    attr_reader :application_form

    def no_work_experience_value
      application_form.full_time_education? ? t('application_form.work_history.full_time_education.label') : application_form.work_history_explanation
    end

    def generate_action(work:, attribute: '')
      if any_jobs_with_same_role_and_organisation?(work)
        "#{attribute.presence} for #{work.role}, #{work.organisation}, #{formatted_start_date(work)} to #{formatted_end_date(work)}"
      else
        "#{attribute.presence} for #{work.role}, #{work.organisation}"
      end
    end

    def working_pattern(work)
      return work.commitment.humanize if work.working_pattern.blank?

      "#{work.commitment.humanize}\n #{work.working_pattern}"
    end

    def breaks_in_work_history?
      CheckBreaksInWorkHistory.call(@application_form)
    end
  end
end
