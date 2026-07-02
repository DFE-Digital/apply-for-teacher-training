module CandidateInterface
  class AfterDeadlineContentComponent < ApplicationComponent
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def relative_application_form
      @relative_application_form ||= if application_form.after_apply_deadline? || application_form.previous_application_form.blank?
                                       application_form
                                     else
                                       application_form.previous_application_form
                                     end
    end

    def recruitment_cycle
      @recruitment_cycle ||= if relative_application_form.after_apply_deadline?
                               relative_application_form.recruitment_cycle_timetable
                             else
                               relative_application_form.recruitment_cycle_timetable.relative_previous_timetable
                             end
    end

    def recruitment_cycle_year
      @recruitment_cycle_year ||= recruitment_cycle.recruitment_cycle_year
    end

    def academic_year
      @academic_year ||= recruitment_cycle.academic_year_range_name
    end

    def january_courses?
      relative_application_form.application_choices
        .course_starts_after_september(recruitment_cycle_year).exists?
    end

    def application_choices
      @application_choices ||= CandidateInterface::SortApplicationChoices.call(
        application_choices: relative_application_form
                               .application_choices
                               .for_sorting,
      )
    end
  end
end
