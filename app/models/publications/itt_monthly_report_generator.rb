module Publications
  class ITTMonthlyReportGenerator
    attr_accessor :generation_date,
                  :publication_date,
                  :month,
                  :first_cycle_week,
                  :report_expected_time,
                  :cycle_week,
                  :model

    delegate :candidate_headline_statistics_query,
             :age_group_query,
             :sex_query,
             :area_query,
             :phase_query,
             :route_into_teaching_query,
             :primary_subject_query,
             :secondary_subject_query,
             :provider_region_query,
             to: ::DfE::Bigquery::ApplicationMetrics

    def initialize(generation_date: Time.zone.now, publication_date: nil, model: MonthlyStatistics::MonthlyStatisticsReport)
      @generation_date = generation_date.to_time
      @publication_date = (publication_date.presence || 1.week.after(@generation_date))
      @first_cycle_week = CycleTimetable.find_opens.beginning_of_week
      @report_expected_time = @generation_date.beginning_of_week(:sunday)
      @cycle_week = (@report_expected_time - first_cycle_week).seconds.in_weeks.round
      @month = @generation_date.strftime('%Y-%m')
      @model = model
    end

    def call
      model.create!(statistics:, generation_date:, publication_date:, month:)
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
        candidate_route_into_teaching: {
          title: I18n.t('publications.itt_monthly_report_generator.route_into_teaching.title'),
          data: candidate_route_into_teaching,
        },
        candidate_primary_subject: {
          title: I18n.t('publications.itt_monthly_report_generator.primary_subject.title'),
          data: candidate_primary_subject,
        },
        candidate_secondary_subject: {
          title: I18n.t('publications.itt_monthly_report_generator.secondary_subject.title'),
          data: candidate_secondary_subject,
        },
        candidate_provider_region: {
          title: I18n.t('publications.itt_monthly_report_generator.provider_region.title'),
          data: candidate_provider_region,
        },
      }
    end
    alias statistics to_h

    def describe
      {
        candidate_headline_statistics_query: candidate_headline_statistics_query(cycle_week:),
        age_group_query: age_group_query(cycle_week:),
        sex_query: sex_query(cycle_week:),
        area_query: area_query(cycle_week:),
        phase_query: phase_query(cycle_week:),
        route_into_teaching_query: route_into_teaching_query(cycle_week:),
        primary_subject_query: primary_subject_query(cycle_week:),
        secondary_subject_query: secondary_subject_query(cycle_week:),
        provider_region_query: provider_region_query(cycle_week:),
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

    def candidate_route_into_teaching
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.route_into_teaching(cycle_week:),
        title_column: :nonsubject_filter,
      )
    end

    def candidate_primary_subject
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.primary_subject(cycle_week:),
        title_column: :subject_filter,
      )
    end

    def candidate_secondary_subject
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.secondary_subject(cycle_week:),
        title_column: :subject_filter,
      )
    end

    def candidate_provider_region
      group_data(
        results: ::DfE::Bigquery::ApplicationMetrics.provider_region(cycle_week:),
        title_column: :nonsubject_filter,
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
