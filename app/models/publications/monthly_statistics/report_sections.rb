module Publications
  module MonthlyStatistics
    module ReportSections
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
end
