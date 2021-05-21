class SyncProvider
  def initialize(provider:)
    @provider = provider
  end

  def call
    @provider.update!(sync_courses: true)
    TeacherTrainingPublicAPI::SyncProviderWorker.perform_async(@provider.code)
  end
end
