module CandidateInterface
  class CarriedOverContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def academic_year
      CycleTimetable.cycle_year_range(recruitment_cycle_year - 1)
    end

    def next_academic_year
      CycleTimetable.cycle_year_range(recruitment_cycle_year)
    end

    def apply_opens_date
      I18n.l(CycleTimetable.apply_reopens.to_date, format: :no_year)
    end

    def after_find_opens?
      Time.zone.now.after? CycleTimetable.find_opens(recruitment_cycle_year)
    end

  private

    def recruitment_cycle_year
      @recruitment_cycle_year ||= @application_form.recruitment_cycle_year
    end
  end
end
