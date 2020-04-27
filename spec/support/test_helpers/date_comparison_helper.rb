module DateComparisonHelper
  # Helper for *just* comparing the days and ignoring time-of-day.
  # Helps to avoid intermittent and hard-to-debug spec failures when
  # comparing two dates that happen to be either side of UTC/BST timezone shift,
  # for which `date1 - date2` will be 82800s, not 86400s (i.e. not >= 1.day)
  def days_between_ignoring_time_of_day(date1, date2)
    date1.to_date - date2.to_date
  end
end
