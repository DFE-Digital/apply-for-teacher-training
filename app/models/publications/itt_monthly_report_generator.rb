module Publications
  class ITTMonthlyReportGenerator
    include MonthlyStatistics::ReportSections
    include MonthlyStatistics::DescribeQueries
    SECTIONS = %i[
      candidate_headline_statistics
      candidate_age_group
      candidate_sex
      candidate_area
      candidate_phase
      candidate_route_into_teaching
      candidate_primary_subject
      candidate_secondary_subject
      candidate_provider_region
      candidate_provider_region_and_subject
      candidate_area_and_subject
    ].freeze

    attr_reader :client,
                :generation_date,
                :publication_date,
                :month,
                :report_expected_time,
                :cycle_week,
                :model

    def initialize(generation_date: Time.zone.now, publication_date: nil, model: MonthlyStatistics::MonthlyStatisticsReport)
      @generation_date = generation_date.to_time
      @publication_date = publication_date.presence || 1.week.after(@generation_date)
      @report_expected_time = @generation_date.beginning_of_week(:sunday)
      @cycle_week = RecruitmentCycleTimetable.find_cycle_week_by_datetime(@report_expected_time)
      @client = DfE::Bigquery::ApplicationMetrics.new(cycle_week:)
      @month = @generation_date.strftime('%Y-%m')
      @model = model
    end

    def call
      model.create!(statistics:, generation_date:, publication_date:, month:)
    end

    def to_h
      report = {
        meta: {
          generation_date:,
          publication_date:,
          period:,
          cycle_week:,
          month:,
        },
        data: {},
        formats: { csv: {} },
      }

      SECTIONS.each do |section_identifier|
        report[:data][section_identifier] = {
          title: I18n.t("publications.itt_monthly_report_generator.#{section_identifier}.title"),
          subtitle: I18n.t("publications.itt_monthly_report_generator.#{section_identifier}.subtitle"),
          data: send(section_identifier),
        }

        report[:formats][:csv][section_identifier] = MonthlyStatistics::CSVSection.new(
          section_identifier:,
          records: bigquery_records[section_identifier],
          title_section: bigquery_title_section[section_identifier],
          headline_statistics: report[:data][:candidate_headline_statistics][:data],
        ).call
      end

      report
    end
    alias statistics to_h

    def period
      "From #{from_date} to #{report_expected_time.to_fs(:govuk_date)}"
    end

    def from_date
      @from_date ||= RecruitmentCycleTimetable.current_timetable.find_opens_at.beginning_of_week.to_fs(:govuk_date)
    end
  end
end
