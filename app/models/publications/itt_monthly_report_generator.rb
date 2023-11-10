module Publications
  class ITTMonthlyReportGenerator
    attr_accessor :generation_date, :publication_date, :first_cycle_week, :report_expected_time, :cycle_week

    delegate :candidate_headline_statistics_query, :age_group_query, :sex_query, :area_query, :phase_query, to: ::DfE::Bigquery::ApplicationMetrics

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
        candidate_sex: {
          title: I18n.t('publications.itt_monthly_report_generator.sex.title'),
          data: candidate_sex,
        },
        candidate_area: {
          title: I18n.t('publications.itt_monthly_report_generator.area.title'),
          data: candidate_area,
        },
        candidate_phase: {
          title: I18n.t('publications.itt_monthly_report_generator.phase.title'),
          data: candidate_phase,
        },
      }
    end

    def describe
      {
        candidate_headline_statistics_query: candidate_headline_statistics_query(cycle_week:),
        age_group_query: age_group_query(cycle_week:),
        sex_query: sex_query(cycle_week:),
        area_query: area_query(cycle_week:),
        phase_query: phase_query(cycle_week:),
      }.each do |key, value|
        # rubocop:disable Rails/Output
        puts "========= #{key.to_s.humanize} =========="
        puts value
        puts '=' * 40
        # rubocop:enable Rails/Output
      end; nil
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

    def candidate_headline_statistics(data = {})
      application_metrics = DfE::Bigquery::ApplicationMetrics.candidate_headline_statistics(cycle_week:)

      data.tap do |_d|
        I18n.t('publications.itt_monthly_report_generator.status').each_key do |status|
          data[status] = {
            title: I18n.t("publications.itt_monthly_report_generator.status.#{status}.title"),
            this_cycle: column_value_for(application_metrics:, status:, cycle: :this_cycle),
            last_cycle: column_value_for(application_metrics:, status:, cycle: :last_cycle),
          }
        end
      end
    end

    def candidate_age_group
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.age_group(cycle_week:),
        title_column: :nonsubject_filter,
      )
    end

    def candidate_sex
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.sex(cycle_week:),
        title_column: :nonsubject_filter,
      )
    end

    def candidate_area
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.area(cycle_week:),
        title_column: :nonsubject_filter,
      )
    end

    def candidate_phase
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.phase(cycle_week:),
        title_column: :subject_filter,
      )
    end

  private

    def group_data(results:, title_column:, data: {})
      data.tap do |_d|
        I18n.t('publications.itt_monthly_report_generator.status').each_key do |status|
          data[status] = results.map do |application_metrics|
            {
              title: application_metrics.send(title_column),
              this_cycle: column_value_for(application_metrics:, status:, cycle: :this_cycle),
              last_cycle: column_value_for(application_metrics:, status:, cycle: :last_cycle),
            }
          end
        end
      end
    end

    def column_value_for(application_metrics:, status:, cycle:)
      application_metrics.send(
        I18n.t("publications.itt_monthly_report_generator.status.#{status}.application_metrics_column.#{cycle}"),
      )
    end
  end
end
