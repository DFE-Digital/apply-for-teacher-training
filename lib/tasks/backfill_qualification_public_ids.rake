desc 'Sets the public_id for qualifications that do not yet have one'
task backfill_qualification_public_ids: :environment do
  ApplicationQualification.where(public_id: nil).each do |qualification|
    BackfillQualificationPublicId.new(qualification).call
  end
end
