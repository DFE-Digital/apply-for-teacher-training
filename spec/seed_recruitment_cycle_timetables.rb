class SeedRecruitmentCycleTimetables
  def self.call
    new.call
  end

  def call
    DataMigrations::AddAllRecruitmentCycleTimetablesToDatabase.new.change
  end
end
