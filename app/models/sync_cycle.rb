module SyncCycle
  def self.current_year
    CycleTimetable.current_sync_year
  end

  def self.next_year
    current_year + 1
  end
end
