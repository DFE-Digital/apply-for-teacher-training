module DataMigrations
  class BackfillTempSites
    TIMESTAMP = 20220517111432
    MANUAL_RUN = true

    include Sidekiq::Worker

    def change
      CycleTimetable::CYCLE_DATES.each_key do |year|
        next if year == CycleTimetable.next_year

        Provider.all.each_with_index do |provider, index|
          delay = calculate_offset(index)

          MigrateTempSitesForProvidersWorker.perform_in(delay, provider.id, year)
        end
      end
    end

  private

    def calculate_offset(index)
      (index * 5).seconds
    end
  end
end
