module Publications
  module MonthlyStatistics
    class MonthlyStatisticsReport < ApplicationRecord
      validates :statistics, :generation_date, :publication_date, :month, presence: true

      scope :published, -> { where('publication_date <= ?', Time.zone.now) }
      scope :drafts, -> { where('publication_date > ?', Time.zone.now) }

      def month_to_date
        Date.parse("#{month}-01")
      end

      def draft?
        Time.zone.today < publication_date
      end

      def v2?
        generation_date > RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2024).find_opens_at
      end

      def self.current_period
        published.order(publication_date: :asc).last
      end

      def self.current_published_report_at(date)
        month = date.strftime('%Y-%m')

        published
          .where(month:)
          .order(created_at: :desc)
          .first!
      end

      def self.report_for_latest_in_cycle(recruitment_cycle_year)
        return current_period if RecruitmentCycleTimetable.current_year == recruitment_cycle_year

        month = latest_month_for(recruitment_cycle_year)

        if month.present?
          current_published_report_at(Date.parse("#{month}-01"))
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def self.latest_month_for(recruitment_cycle_year)
        period = RecruitmentCycleTimetable.find_by!(recruitment_cycle_year:)&.apply_deadline_at
        [period.year, period.month].join('-')
      end
    end
  end
end
