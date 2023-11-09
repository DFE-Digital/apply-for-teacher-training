module Publications
  class ITTMonthlyReportGenerator
    attr_reader :generation_date, :first_cycle_week, :report_expected_time, :cycle_week

    def initialize(generation_date: Time.zone.now)
      @generation_date = generation_date
      @first_cycle_week = CycleTimetable.find_opens.beginning_of_week
      @report_expected_time = @generation_date.beginning_of_week(:sunday)
      @cycle_week = (@report_expected_time - first_cycle_week).seconds.in_weeks.round
    end

    def to_h
      {
        meta:,
        candidate_headline_statistics: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.title'),
          data: candidate_headline_statistics,
        },
      }
    end

    def meta
      {
        generation_date:,
        period:,
        cycle_week:,
      }
    end

    def period
      "From #{first_cycle_week.to_fs(:govuk_date)} to #{report_expected_time.to_fs(:govuk_date)}"
    end

    def candidate_headline_statistics
      application_metrics = DfE::Bigquery::ApplicationMetrics.candidate_headline_statistics(cycle_week:)

      {
        submitted: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.submitted.title'),
          this_cycle: application_metrics.number_of_candidates_submitted_to_date,
          last_cycle: application_metrics.number_of_candidates_submitted_to_same_date_previous_cycle,
        },
        with_offers: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.with_offers.title'),
          this_cycle: application_metrics.number_of_candidates_with_offers_to_date,
          last_cycle: application_metrics.number_of_candidates_with_offers_to_same_date_previous_cycle,
        },
        accepted: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.accepted.title'),
          this_cycle: application_metrics.number_of_candidates_accepted_to_date,
          last_cycle: application_metrics.number_of_candidates_accepted_to_same_date_previous_cycle,
        },
        rejected: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.rejected.title'),
          this_cycle: application_metrics.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date,
          last_cycle: application_metrics.number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle,
        },
        reconfirmed: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.reconfirmed.title'),
          this_cycle: application_metrics.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date,
          last_cycle: application_metrics.number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle,
        },
        deferred: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.deferred.title'),
          this_cycle: application_metrics.number_of_candidates_with_deferred_offers_from_this_cycle_to_date,
          last_cycle: application_metrics.number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle,
        },
        withdrawn: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.withdrawn.title'),
          this_cycle: application_metrics.number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date,
          last_cycle: application_metrics.number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle,
        },
        conditions_not_met: {
          title: I18n.t('publications.itt_monthly_report_generator.candidate_headline_statistics.conditions_not_met.title'),
          this_cycle: application_metrics.number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date,
          last_cycle: application_metrics.number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle,
        },
      }
    end
  end
end
