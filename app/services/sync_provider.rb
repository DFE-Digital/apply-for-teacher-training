class SyncProvider
  def initialize(provider:)
    @provider = provider
  end

  def call
    TeacherTrainingPublicAPI::SyncProviderWorker.perform_async(@provider.code)
  end
end
