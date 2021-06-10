module TeacherTrainingPublicAPI
  class SyncProviderWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_code)
      provider_from_api = Provider.fetch(provider_code)

      if provider_from_api.present?
        TeacherTrainingPublicAPI::SyncProvider.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: ::RecruitmentCycle.current_year,
        ).call
      end
    end
  end
end
