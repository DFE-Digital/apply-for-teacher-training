class MonthlyStatisticsReport < ApplicationRecord
  MISSING_VALUE = 'n/a'.freeze

  def write_statistic(key, value)
    self.statistics = (statistics || {}).merge(key.to_s => value)
  end

  def read_statistic(key)
    statistics[key.to_s] || MISSING_VALUE
  end

  def load_table_data
    load_applications_by_status
    load_candidates_by_status
    load_by_course_age_group
    load_by_sex
  end

private

  def load_by_course_age_group
    write_statistic(
      :by_course_age_group,
      MonthlyStatistics::ByCourseAgeGroup.new.table_data,
    )
  end

  def load_by_sex
    write_statistic(
      :by_sex,
      MonthlyStatistics::BySex.new.table_data,
    )
  end

  def load_applications_by_status
    write_statistic(
      :applications_by_status,
      MonthlyStatistics::ByStatus.new.table_data,
    )
  end

  def load_candidates_by_status
    write_statistic(
      :candidates_by_status,
      MonthlyStatistics::ByStatus.new(by_candidate: true).table_data,
    )
  end
end
