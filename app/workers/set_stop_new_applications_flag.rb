class SetStopNewApplicationsFlag
  include Sidekiq::Worker

  # TODO: These could be env vars
  PAUSE_ON = Date.new(2020, 8, 24)
  RESUME_ON = Date.new(2020, 9, 7)

  def perform
    if Time.zone.now.to_date == PAUSE_ON
      FeatureFlag.activate(:stop_new_applications)
    elsif Time.zone.now.to_date == RESUME_ON
      FeatureFlag.deactivate(:stop_new_applications)
    end
  end
end
