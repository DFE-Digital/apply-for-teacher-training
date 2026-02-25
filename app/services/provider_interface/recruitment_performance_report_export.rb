require 'zip'

module ProviderInterface
  class RecruitmentPerformanceReportExport
    include ActiveSupport::NumberHelper

    attr_reader :provider, :region, :report_type, :provider_report

    CANDIDATES_WHO_HAVE_SUBMITTED_APPLICATIONS = 'candidates_who_have_submitted_applications'.freeze
    CANDIDATES_THAT_RECEIVED_AN_OFFER = 'candidates_that_received_an_offer'.freeze
    PROPORTION_OF_CANDIDATES_WITH_AN_OFFER = 'proportion_of_candidates_with_an_offer'.freeze
    OFFERS_ACCEPTED = 'offers_accepted'.freeze
    DEFERRALS = 'deferrals'.freeze
    CANDIDATES_REJECTED = 'candidates_rejected'.freeze
    WAITING_FOR_A_RESPONSE = 'proportion_of_candidates_who_have_waited_more_than_30_working_days_for_a_response'.freeze
    REPORTS = [
      CANDIDATES_WHO_HAVE_SUBMITTED_APPLICATIONS,
      CANDIDATES_THAT_RECEIVED_AN_OFFER,
      PROPORTION_OF_CANDIDATES_WITH_AN_OFFER,
      OFFERS_ACCEPTED,
      DEFERRALS,
      CANDIDATES_REJECTED,
      WAITING_FOR_A_RESPONSE,
    ].freeze

    def initialize(provider:, region:, provider_report: nil, report_type: :NATIONAL)
      @provider = provider
      @region = region
      @provider_report = provider_report || latest_report
      @report_type = report_type
    end

    def call
      return if provider_report.blank?

      export_folder = "tmp/#{Time.zone.today}-rpr-export"
      timestamp = Time.zone.now.strftime('%Y%m%d_%H%M%S')

      FileUtils.mkdir_p(export_folder)

      REPORTS.each do |report_name|
        send("#{report_name}_report", export_folder, timestamp)
      end

      zip_filename = "#{export_folder}.zip"
      Zip::OutputStream.open(zip_filename) do |zos|
        REPORTS.each do |csv_report|
          csv_filename = "#{csv_report}_#{timestamp}.csv"
          zos.put_next_entry(csv_filename)
          zos.write(File.read("#{export_folder}/#{csv_filename}"))
        end
      end

      FileUtils.remove_dir(export_folder)

      zip_filename
    end

  private

    def candidates_who_have_submitted_applications_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::SubmittedApplicationsTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping)
      file_name = CANDIDATES_WHO_HAVE_SUBMITTED_APPLICATIONS
      rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:)
    end

    def candidates_that_received_an_offer_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::CandidatesWithOffersTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping)
      file_name = CANDIDATES_THAT_RECEIVED_AN_OFFER
      rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:)
    end

    def proportion_of_candidates_with_an_offer_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::ProportionCandidatesWithOffersTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping)
      file_name = PROPORTION_OF_CANDIDATES_WITH_AN_OFFER
      rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:, percentage_values: true)
    end

    def offers_accepted_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::OffersAcceptedTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping)
      file_name = OFFERS_ACCEPTED
      rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:)
    end

    def deferrals_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::DeferralsTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping, service: ProviderInterface::Reports::DeferralRowsBuilderService)
      file_name = DEFERRALS

      CSV.open("#{export_folder}/#{file_name}_#{timestamp}.csv", 'w', headers: true) do |csv|
        csv << ['Deferrals', provider.name, region_title]
        rows.deferral_rows.each do |deferral_row|
          csv << [
            deferral_row.title.to_s.humanize,
            deferral_row.provider_deferrals_count,
            deferral_row.national_deferrals_count,
          ]
        end
      end
    end

    def candidates_rejected_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::CandidatesRejectedTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping)
      file_name = CANDIDATES_REJECTED
      rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:)
    end

    def proportion_of_candidates_who_have_waited_more_than_30_working_days_for_a_response_report(export_folder, timestamp)
      field_mapping = RecruitmentPerformanceReport::ProportionWithInactiveApplicationsTableComponent::BIG_QUERY_COLUMN_NAMES_MAPPING
      rows = build_subject_rows(field_mapping)
      file_name = WAITING_FOR_A_RESPONSE
      rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:, percentage_values: true)
    end

    def rows_to_csv(file_name:, rows:, field_mapping:, export_folder:, timestamp:, percentage_values: false)
      summary_row = rows.summary_row

      CSV.open("#{export_folder}/#{file_name}_#{timestamp}.csv", 'w', headers: true) do |csv|
        row_methods = if field_mapping.keys.include?(:percentage_change)
                        csv << ['', provider.name, '', '', region_title, '', '']
                        csv << ['Subject', 'Last cycle', 'This cycle', 'Percentage change', 'Last cycle', 'This cycle', 'Percentage change']
                        %w[last_cycle this_cycle percentage_change national_last_cycle national_this_cycle national_percentage_change]
                      else
                        csv << ['', provider.name, '', region_title, '']
                        csv << ['Subject', 'Last cycle', 'This cycle', 'Last cycle', 'This cycle']
                        %w[last_cycle this_cycle national_last_cycle national_this_cycle]
                      end
        rows.subject_rows.each do |subject_row|
          csv << format_row(row: subject_row, row_methods:, summary: false, percentage_values: percentage_values)
        end

        csv << format_row(row: summary_row, row_methods:, summary: true, percentage_values: percentage_values)
      end
    end

    def format_row(row:, row_methods:, summary: false, percentage_values: false)
      formatted_row = summary ? ['All subjects'] : [row.title]
      row_methods.each do |row_method|
        as_percentage = %w[percentage_change national_percentage_change].include?(row_method) || percentage_values
        formatted_row << format_number(number: row.try(row_method), percentage: percentage_values, as_percentage:)
      end
      formatted_row
    end

    def format_number(number:, percentage: false, as_percentage: false)
      return number unless as_percentage
      return 'Not available' if number.nil?

      if percentage
        number_to_percentage(number * 100, precision: 0)
      else
        number_to_percentage((number - 1) * 100, precision: 0)
      end
    end

    def build_subject_rows(field_mapping, service: ProviderInterface::Reports::SubjectRowsBuilderService)
      service.new(
        field_mapping:,
        provider_statistics: provider_report.statistics,
        statistics:,
        report_type:,
      )
    end

    def statistics
      @statistics ||= report_type == :NATIONAL ? national_report&.statistics : regional_report&.statistics
    end

    def regional_report
      @regional_report ||=
        Publications::RegionalRecruitmentPerformanceReport.where(
          cycle_week: provider_report.cycle_week,
          region:,
        ).last
    end

    def national_report
      @national_report ||=
        Publications::NationalRecruitmentPerformanceReport.where(
          cycle_week: provider_report.cycle_week,
        ).last
    end

    def latest_report
      @latest_report ||=
        Publications::ProviderRecruitmentPerformanceReport
          .where(provider: provider)
          .order(:recruitment_cycle_year, :cycle_week)
          .last
    end

    def region_title
      @region_title ||= if report_type == :NATIONAL
                          'All providers'
                        else
                          I18n.t("shared.#{region}")
                        end
    end
  end
end
