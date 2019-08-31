class WorkingDay
  def self.is_working_day?(date)
    date.on_weekday?
  end
end
