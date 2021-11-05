module RegionCodeBackfill
  BATCH_SIZE = 50
  INTERVAL_BETWEEN_BATCHES = 5.seconds
end

desc 'Generate mappings'
task region_code_backfill: :environment do
  raise '`region_from_postcode` feature flag must be enabled to run this task' unless FeatureFlag.active?(:region_from_postcode)

  next_batch_time = Time.zone.now + 1.minute
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
