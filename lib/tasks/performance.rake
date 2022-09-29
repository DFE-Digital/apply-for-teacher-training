namespace :performance do
  desc 'Benchmark the activity log query used on Application Timeline and Support UI'
  task benchmark_activity_log_query: :environment do
    # Get provider ids for applications with the highest number of audit associations.
    provider_ids = ApplicationForm
      .includes(:application_choices)
      .where(
        id: Audited::Audit
              .where(associated_type: 'ApplicationForm')
              .group(:associated_id)
              .order(Arel.sql('COUNT(audits.associated_id) DESC'))
              .limit(5)
              .pluck(:associated_id)
              .uniq,
      ).pluck('application_choices.provider_ids').flatten.uniq

    application_choices = GetApplicationChoicesForProviders.call(providers: Provider.where(id: provider_ids.take(5)))

    benchmarks = []
    12.times do
      benchmarks << Benchmark.measure { GetActivityLogEvents.call(application_choices: application_choices) }.real
    end

    # Discard first and last benchmark.
    benchmarks.shift
    benchmarks.pop

    average = benchmarks.sum(0.0) / benchmarks.size

    Rails.logger.info "GetActivityLogEvents average execution time for #{application_choices.size} applications:"
    Rails.logger.info "#{average} seconds."
    Rails.logger.info '-----------------------------------------------------------------------------------------'
  end
end
