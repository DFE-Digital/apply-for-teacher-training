module DataMigrations
  class RemoveIntersexFromReports
    TIMESTAMP = 20230125162341
    MANUAL_RUN = false

    def change
      Publications::MonthlyStatistics::MonthlyStatisticsReport
        .where(month: %w[2022-10 2022-11 2022-12 2023-01 2023-02])
        .find_each do |report|
          if (rows = report.statistics.dig('by_sex', 'rows')).any? { |r| r['Sex'] == 'Intersex' }
            rows.delete_if { |r| r['Sex'] == 'Intersex' }
            report.save!
          end
        end
    end
  end
end
