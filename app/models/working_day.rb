class WorkingDay
  def self.is_working_day?(date)
    date.workday?
  end
end
