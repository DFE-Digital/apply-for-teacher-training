module ProductionRecruitmentCycleTimetablesAPI
  class SyncTimetablesWithProduction
    def call
      response = Client.new.fetch_all_recruitment_cycles.fetch('data', [])
      ::SeedTimetablesService.new(response).call
    end
  end
end
