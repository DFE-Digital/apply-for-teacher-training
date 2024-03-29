module RegionCodeBackfill
  BATCH_SIZE = 50
  INTERVAL_BETWEEN_BATCHES = 5.seconds
end

desc 'Generate mappings'
task region_code_backfill: :environment do
  next_batch_time = 1.minute.from_now
  ApplicationForm
    .where(region_code: nil)
    .where.not(postcode: nil)
    .find_in_batches(batch_size: RegionCodeBackfill::BATCH_SIZE) do |batch|
      batch.each do |application_form|
        LookupAreaByPostcodeWorker.perform_at(next_batch_time, application_form.id)
      end
      next_batch_time += RegionCodeBackfill::INTERVAL_BETWEEN_BATCHES
    end
end
