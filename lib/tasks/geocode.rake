namespace :geocode do
  desc 'Geocode candidate addresses'
  task candidate_addresses: :environment do
    if Geocoder.config.api_key.blank?
      raise 'You need to set a GOOGLE_MAPS_API_KEY'
    end

    Benchmark.bm do |x|
      x.report do
        ApplicationForm.where.not(address_line1: nil).find_in_batches do |application_batch|
          application_batch.each_slice(10) do |slice|
            threads = slice.map do |application|
              Thread.new do
                application.latitude, application.longitude = application.geocode
                application.save!
              end
            end
            threads.each(&:join)
            sleep(0.25)
          end
        end
      end
    end
  end
end
