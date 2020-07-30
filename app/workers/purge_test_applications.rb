class PurgeTestApplications
  include Sidekiq::Worker

  def perform(*)
  end
end
