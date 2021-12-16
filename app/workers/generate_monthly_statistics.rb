class GenerateMonthlyStatistics
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform
    return false unless MonthlyStatisticsTimetable.generate_monthly_statistics?

    dashboard = Publications::MonthlyStatistics::MonthlyStatisticsReport.new
    dashboard.load_table_data
    dashboard.save!

    DataExport::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
      export = DataExport.create!(
        name: DataExport::EXPORT_TYPES[export_type.to_sym][:name],
        export_type: export_type,
      )

      DataExporter.perform_async(DataExport::EXPORT_TYPES[export_type.to_sym][:class], export.id, {})
    end
  end
end
