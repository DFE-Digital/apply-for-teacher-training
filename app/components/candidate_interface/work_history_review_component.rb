module CandidateInterface
  class WorkHistoryReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @work_history_with_breaks = WorkHistoryWithBreaks.new(@application_form).timeline
    end

    def work_experience_rows(work)
      [
        role_row(work),
        organisation_row(work),
        working_pattern_row(work),
        dates_row(work),
        details_row(work),
        working_with_children_row(work),
      ]
        .compact
    end

    def no_work_experience_rows
      [
        {
          key: t('application_form.work_history.explanation.review_label'),
          value: @application_form.work_history_explanation,
          action: t('application_form.work_history.explanation.change_action'),
          change_path: candidate_interface_work_history_explanation_path,
        },
      ]
    end

    def break_in_work_history_rows
      [
        {
          key: t('application_form.work_history.breaks.review_label'),
          value: @application_form.work_history_breaks,
        },
      ]
    end

    def show_missing_banner?
      @show_incomplete
    end

    def show_consolidated_work_history_breaks?
      breaks_in_work_history? && @application_form.work_history_breaks
    end

    def show_break_placeholders?
      @application_form.work_history_breaks.blank? && @editable
    end

  private

    attr_reader :application_form

    def role_row(work)
      {
        key: t('application_form.work_history.role.review_label'),
        value: work.role,
        action: generate_action(work: work, attribute: t('application_form.work_history.role.change_action')),
        change_path: candidate_interface_work_history_edit_path(work.id),
      }
    end

    def organisation_row(work)
      {
        key: t('application_form.work_history.organisation.review_label'),
        value: work.organisation,
        action: generate_action(work: work, attribute: t('application_form.work_history.organisation.change_action')),
        change_path: candidate_interface_work_history_edit_path(work.id),
      }
    end

    def working_pattern_row(work)
      {
        key: t('application_form.work_history.working_pattern.review_label'),
        value: working_pattern(work),
        action: generate_action(work: work, attribute: t('application_form.work_history.working_pattern.change_action')),
        change_path: candidate_interface_work_history_edit_path(work.id),
      }
    end

    def dates_row(work)
      {
        key: t('application_form.work_history.dates.review_label'),
        value: "#{formatted_start_date(work)} - #{formatted_end_date(work)}",
        action: generate_action(work: work, attribute: t('application_form.work_history.dates.change_action')),
        change_path: candidate_interface_work_history_edit_path(work.id),
      }
    end

    def details_row(work)
      {
        key: t('application_form.work_history.details.review_label'),
        value: work.details,
        action: generate_action(work: work, attribute: t('application_form.work_history.details.change_action')),
        change_path: candidate_interface_work_history_edit_path(work.id),
      }
    end

    def working_with_children_row(work)
      {
        key: t('application_form.work_history.working_with_children.review_label'),
        value: work.working_with_children ? t('application_form.work_history.working_with_children.yes.label') : t('application_form.work_history.working_with_children.no.label'),
        action: generate_action(work: work, attribute: t('application_form.work_history.working_with_children.change_action')),
        change_path: candidate_interface_work_history_edit_path(work.id),
      }
    end

    def formatted_start_date(work)
      work.start_date.to_s(:month_and_year)
    end

    def formatted_end_date(work)
      return 'Present' if work.end_date.nil?

      work.end_date.to_s(:month_and_year)
    end

    def generate_action(work:, attribute: '')
      if any_jobs_with_same_role_and_organisation?(work)
        "#{attribute.presence} for #{work.role}, #{work.organisation}, #{formatted_start_date(work)} to #{formatted_end_date(work)}"
      else
        "#{attribute.presence} for #{work.role}, #{work.organisation}"
      end
    end

    def any_jobs_with_same_role_and_organisation?(work)
      jobs = @application_form.application_work_experiences.where(role: work.role, organisation: work.organisation)
      jobs.many?
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
