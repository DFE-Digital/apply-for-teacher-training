module CandidateInterface
  class AfterDeadlineContentComponent < ViewComponent::Base
    delegate :decline_by_default_at, :after_apply_deadline?, to: :timetable
    delegate :after_find_opens?,
             :current_recruitment_cycle?,
             :academic_year_range_name,
             :can_submit_more_choices?,
             to: :@application_form, prefix: :application_form
    delegate :before_apply_opens?,
             :before_find_opens?,
             :find_opens_at,
             :apply_opens_at,
             to: :next_timetable

    attr_reader :application_form
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      if application_form.after_apply_deadline?
        application_form_academic_year_range_name
      elsif application_form.previous_application_form.present?
        application_form.previous_application_form.academic_year_range_name
      else
        timetable.academic_year_range_name
      end
    end

    def next_academic_year
      next_timetable.academic_year_range_name
    end

    def application_form_start_month_year
      if application_form.previous_application_form.present?
        application_form.previous_application_form.recruitment_cycle_timetable
      else
        timetable
      end.apply_deadline_at.to_fs(:month_and_year)
    end

    def next_academic_cycle
      next_timetable.academic_year_range_name
    end

    def next_start_month
      next_timetable.apply_deadline_at.to_fs(:month_and_year)
    end

    def apply_opens_date
      apply_opens_at.to_fs(:day_and_month)
    end

    def date_and_time_find_opens
      find_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def date_and_time_apply_opens
      apply_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def find_opens_text
      t(
        '.when_find_opens_html',
        find_link: govuk_link_to(t('.find_link_text'), t('find_teacher_training.production_url')),
        find_opens_at: find_opens_at.to_fs(:govuk_date_time_time_first),
      )
    end

    def apply_opens_text
      t(
        '.when_apply_opens',
        apply_opens_at: apply_opens_at.to_fs(:govuk_date_time_time_first),
      )
    end

    def application_choices_conditional_content
      return [] if application_choices.blank?

      [
        reject_by_default_warning_text,
        reject_by_default_explanation,
        decline_by_default_warning_text,
        decline_by_default_explanation,
      ].compact_blank
    end

    def reject_by_default_warning_text
      if application_choices.any?(&:decision_pending?)
        t(
          '.reject_by_default_warning_text_html',
          reject_by_default_at: @application_form.reject_by_default_at.to_fs(:govuk_date_and_time),
        )
      end
    end

    def reject_by_default_explanation
      if application_choices.any?(&:rejected_by_default?)
        t(
          '.reject_by_default_explanation',
          reject_by_default_at: @application_form.reject_by_default_at.to_fs(:govuk_date_time_time_first),
        )
      end
    end

    def decline_by_default_warning_text
      if application_choices.any?(&:offer?)
        t(
          '.decline_by_default_warning_html',
          decline_by_default_at: @application_form.decline_by_default_at.to_fs(:govuk_date_and_time),
        )
      end
    end

    def decline_by_default_explanation
      if application_choices.any?(&:declined_by_default?)
        t(
          '.decline_by_default_explanation',
          decline_by_default_at: @application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first),
        )
      end
    end

    def show_button?
      application_form_after_find_opens? && !after_apply_deadline? &&
        application_form_can_submit_more_choices?
    end

  private

    def application_choices
      @application_choices ||= @application_form.application_choices
    end

    def timetable
      @timetable ||= @application_form.recruitment_cycle_timetable
    end

    def next_timetable
      @next_timetable ||= if RecruitmentCycleTimetable.current_timetable.after_apply_deadline?
                            RecruitmentCycleTimetable.next_timetable
                          else
                            RecruitmentCycleTimetable.current_timetable
                          end
    end
  end
end
