module Publications
  class ITTMonthlyReportGenerator
    attr_accessor :generation_date, :publication_date, :first_cycle_week, :report_expected_time, :cycle_week

    def initialize(generation_date: Time.zone.now, publication_date: nil)
      @generation_date = generation_date
      @publication_date = (publication_date.presence || 1.week.after(@generation_date))
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
        candidate_age_group: {
          title: I18n.t('publications.itt_monthly_report_generator.age_group.title'),
          data: candidate_age_group,
        },
      }
    end

    def meta
      {
        generation_date:,
        publication_date:,
        period:,
        cycle_week:,
      }
    end

    def period
      "From #{first_cycle_week.to_fs(:govuk_date)} to #{report_expected_time.to_fs(:govuk_date)}"
    end

    def candidate_headline_statistics
      application_metrics = DfE::Bigquery::ApplicationMetrics.candidate_headline_statistics(cycle_week:)
      data = {}

      I18n.t('publications.itt_monthly_report_generator.status').each_key do |status|
        data[status] = {
          title: I18n.t("publications.itt_monthly_report_generator.status.#{status}.title"),
          this_cycle: column_value_for(application_metrics:, status:, cycle: :this_cycle),
          last_cycle: column_value_for(application_metrics:, status:, cycle: :last_cycle),
        }
      end

      data
    end

    def candidate_age_group
      results = ::DfE::Bigquery::ApplicationMetrics.age_group(cycle_week:)

      data = {}

      I18n.t('publications.itt_monthly_report_generator.status').each_key do |status|
        data[status] = results.map do |application_metrics|
          {
            title: application_metrics.nonsubject_filter,
            this_cycle: column_value_for(application_metrics:, status:, cycle: :this_cycle),
            last_cycle: column_value_for(application_metrics:, status:, cycle: :last_cycle),
          }
        end
      end

      data
    end

  private

    def column_value_for(application_metrics:, status:, cycle:)
      application_metrics.send(
        I18n.t("publications.itt_monthly_report_generator.status.#{status}.application_metrics_column.#{cycle}"),
      )
    end
  end
end
