module Publications
  module MonthlyStatistics
    class DeferredApplications
      def count
        ApplicationForm
          .joins(:application_choices)
          .where('application_choices.current_recruitment_cycle_year > application_forms.recruitment_cycle_year')
          .distinct('application_forms.id')
          .count
      end
    end
  end
end
