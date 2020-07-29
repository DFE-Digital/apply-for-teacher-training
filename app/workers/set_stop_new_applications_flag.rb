class SetStopNewApplicationsFlag
  include Sidekiq::Worker

  # TODO: These could be env vars
  APPLY_PAUSE_ON = Date.new(2020, 8, 24)
  APPLY_AGAIN_PAUSE_ON = Date.new(2020, 9, 18)
  RESUME_ON = Date.new(2020, 10, 13)

  def perform
    if Time.zone.now.to_date == APPLY_PAUSE_ON
      FeatureFlag.activate(:stop_new_applications)
    elsif Time.zone.now.to_date == APPLY_AGAIN_PAUSE_ON
      FeatureFlag.activate(:stop_new_apply_again_applications)
    elsif Time.zone.now.to_date == RESUME_ON
      FeatureFlag.deactivate(:stop_new_applications)
      FeatureFlag.deactivate(:stop_new_apply_again_applications)
    end
  end
end
