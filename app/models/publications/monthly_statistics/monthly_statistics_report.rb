module Publications
  module MonthlyStatistics
    class MonthlyStatisticsReport < ApplicationRecord
      validates :statistics, :generation_date, :publication_date, :month, presence: true

      scope :published, -> { where('publication_date <= ?', Time.zone.today) }
      scope :drafts, -> { where('publication_date > ?', Time.zone.today) }

      def month_to_date
        Date.parse("#{month}-01")
      end

      def draft?
        Time.zone.today < publication_date
      end

      def v2?
        generation_date > RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2024).find_opens_at
      end

      def self.latest_published_report
        published.order(generation_date: :asc).last!
      end

      def self.report_for_latest_in_cycle(recruitment_cycle_year)
        timetable = RecruitmentCycleTimetable.find_by!(recruitment_cycle_year: recruitment_cycle_year)

        report = published.where(generation_date: timetable.find_opens_at..timetable.find_closes_at)
                          .order(:generation_date)
                          .last

        report.presence || raise(ActiveRecord::RecordNotFound)
      end
    end
  end
end
