module Publications
  module MonthlyStatistics
    module ReportSections
      def bigquery_records
        @bigquery_records ||= {
          candidate_headline_statistics: DfE::Bigquery::ApplicationMetrics.candidate_headline_statistics(cycle_week:),
          candidate_age_group: ::DfE::Bigquery::ApplicationMetrics.age_group(cycle_week:),
          candidate_sex: ::DfE::Bigquery::ApplicationMetrics.sex(cycle_week:),
          candidate_area: ::DfE::Bigquery::ApplicationMetrics.area(cycle_week:),
          candidate_phase: ::DfE::Bigquery::ApplicationMetrics.phase(cycle_week:),
          candidate_route_into_teaching: ::DfE::Bigquery::ApplicationMetrics.route_into_teaching(cycle_week:),
          candidate_primary_subject: ::DfE::Bigquery::ApplicationMetrics.primary_subject(cycle_week:),
          candidate_secondary_subject: ::DfE::Bigquery::ApplicationMetrics.secondary_subject(cycle_week:),
          candidate_provider_region: ::DfE::Bigquery::ApplicationMetrics.provider_region(cycle_week:),
          candidate_provider_region_and_subject: ::DfE::Bigquery::ApplicationMetrics.provider_region_and_subject(cycle_week:),
          candidate_area_and_subject: ::DfE::Bigquery::ApplicationMetrics.candidate_area_and_subject(cycle_week:),
        }
      end

      def bigquery_title_section
        @bigquery_title_section ||= {
          candidate_age_group: :nonsubject_filter,
          candidate_sex: :nonsubject_filter,
          candidate_area: :nonsubject_filter,
          candidate_phase: :subject_filter,
          candidate_route_into_teaching: :nonsubject_filter,
          candidate_primary_subject: :subject_filter,
          candidate_secondary_subject: :subject_filter,
          candidate_provider_region: :nonsubject_filter,
          candidate_provider_region_and_subject: {
            title_column: :nonsubject_filter,
            extra_columns: { subject: { attribute: :subject_filter } },
          },
          candidate_area_and_subject: {
            title_column: :nonsubject_filter,
            extra_columns: { subject: { attribute: :subject_filter } },
          },
        }
      end

      def candidate_headline_statistics(data = {})
        application_metrics = bigquery_records[:candidate_headline_statistics]

        I18n.t('publications.itt_monthly_report_generator.status').each_key do |status|
          data[status] = {
            title: I18n.t("publications.itt_monthly_report_generator.status.#{status}.title"),
            this_cycle: column_value_for(application_metrics:, status:, cycle: :this_cycle),
            last_cycle: column_value_for(application_metrics:, status:, cycle: :last_cycle),
          }
        end

        data.reject do |_, status_data|
          ::Publications::MonthlyStatistics::StatisticsDataProcessor.new(status_data:).violates_gdpr?
        end
      end

      def candidate_age_group
        group_data_for_report(
          results: bigquery_records[:candidate_age_group],
          title_column: bigquery_title_section[:candidate_age_group],
        )
      end

      def candidate_sex
        group_data_for_report(
          results: bigquery_records[:candidate_sex],
          title_column: bigquery_title_section[:candidate_sex],
        )
      end

      def candidate_area
        group_data_for_report(
          results: bigquery_records[:candidate_area],
          title_column: bigquery_title_section[:candidate_area],
        )
      end

      def candidate_phase
        group_data_for_report(
          results: bigquery_records[:candidate_phase],
          title_column: bigquery_title_section[:candidate_phase],
        )
      end

      def candidate_route_into_teaching
        group_data_for_report(
          results: bigquery_records[:candidate_route_into_teaching],
          title_column: bigquery_title_section[:candidate_route_into_teaching],
        )
      end

      def candidate_primary_subject
        group_data_for_report(
          results: bigquery_records[:candidate_primary_subject],
          title_column: bigquery_title_section[:candidate_primary_subject],
        )
      end

      def candidate_secondary_subject
        group_data_for_report(
          results: bigquery_records[:candidate_secondary_subject],
          title_column: bigquery_title_section[:candidate_secondary_subject],
        )
      end

      def candidate_provider_region
        group_data_for_report(
          results: bigquery_records[:candidate_provider_region],
          title_column: bigquery_title_section[:candidate_provider_region],
        )
      end

      def candidate_provider_region_and_subject
        group_data_for_report(
          results: bigquery_records[:candidate_provider_region_and_subject],
          title_column: bigquery_title_section[:candidate_provider_region_and_subject][:title_column],
          extra_columns: bigquery_title_section[:candidate_provider_region_and_subject][:extra_columns],
        )
      end

      def candidate_area_and_subject
        group_data_for_report(
          results: bigquery_records[:candidate_area_and_subject],
          title_column: bigquery_title_section[:candidate_area_and_subject][:title_column],
          extra_columns: bigquery_title_section[:candidate_area_and_subject][:extra_columns],
        )
      end

    private

      def group_data_for_report(results:, title_column:, data: {}, extra_columns: {})
        I18n.t('publications.itt_monthly_report_generator.status').each_key do |status|
          data[status] = results.map do |application_metrics|
            {
              title: application_metrics.send(title_column),
              this_cycle: column_value_for(application_metrics:, status:, cycle: :this_cycle),
              last_cycle: column_value_for(application_metrics:, status:, cycle: :last_cycle),
            }.tap do |row|
              extra_columns.each do |field, column|
                row[field] = application_metrics.send(column[:attribute])
              end
            end
          end
        end

        data.reject do |_, status_data|
          ::Publications::MonthlyStatistics::StatisticsDataProcessor.new(status_data:).violates_gdpr?
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
