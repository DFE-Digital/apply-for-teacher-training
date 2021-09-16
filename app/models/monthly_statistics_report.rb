class MonthlyStatisticsReport < ApplicationRecord
  MISSING_VALUE = 'n/a'.freeze

  def write_statistic(key, value)
    self.statistics = (statistics || {}).merge(key.to_s => value)
  end

  def read_statistic(key)
    statistics[key.to_s] || MISSING_VALUE
  end

  def load_updated_statistics
    load_by_course_age_group
  end

private

  def load_by_course_age_group
    write_statistic(
      :by_course_age_group,
      CourseAgeGroupMonthlyStatistics.new.call,
    )
  end
end
