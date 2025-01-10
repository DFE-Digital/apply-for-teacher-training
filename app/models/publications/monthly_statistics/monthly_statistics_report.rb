module Publications
  module MonthlyStatistics
    class MonthlyStatisticsReport < ApplicationRecord
      validates :statistics, :generation_date, :publication_date, :month, presence: true

      def month_to_date
        Date.parse("#{month}-01")
      end

      def draft?
        Time.zone.today < publication_date
      end

      def v2?
        generation_date > CycleTimetable.find_opens(2024)
      end

      def self.current_period
        if MonthlyStatisticsTimetable.next_publication_date > Time.zone.today
          current_report_at(MonthlyStatisticsTimetable.last_publication_date)
        else
          current_report_at(Time.zone.today)
        end
      end

      def self.current_report_at(date)
        month = date.strftime('%Y-%m')

        where(month:)
        .order(created_at: :desc)
        .first!
      end

      def self.report_for_latest_in_cycle(recruitment_cycle_year)
        return current_period if CycleTimetable.current_year == recruitment_cycle_year

        month = latest_month_for(recruitment_cycle_year)

        if month.present?
          current_report_at(Date.parse("#{month}-01"))
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def self.latest_month_for(recruitment_cycle_year)
        return if CycleTimetable.real_schedule_for(recruitment_cycle_year).blank?

        period = CycleTimetable.apply_deadline(recruitment_cycle_year)
        [period.year, period.month].join('-')
      end
    end
  end
end
