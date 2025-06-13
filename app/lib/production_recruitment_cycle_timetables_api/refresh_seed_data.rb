module ProductionRecruitmentCycleTimetablesAPI
  class RefreshSeedData
    def call
      timetables = client.fetch_all_recruitment_cycles.fetch('data')
      headers = timetables.first.keys

      CSV.open('config/initializers/cycle_timetables.csv', 'w', headers: true) do |csv|
        csv << headers
        timetables.each do |timetable|
          row = headers.map { |header| timetable[header] }
          csv << row
        end
      end
    end

  private

    def client
      @client ||= Client.new
    end
  end
end
