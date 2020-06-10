class SendCourseFullNotificationsWorker
  include Sidekiq::Worker

  def perform
    return unless FeatureFlag.active?(:unavailable_course_notifications)

    GetApplicationChoicesWithNewlyUnavailableCourses.call.each do |application_choice|
      reason = ReasonCourseNotAvailable.new(application_choice).call
      ChaserSent.create!(
        chased: application_choice,
        chaser_type: :course_unavailable_notification,
      )
      CandidateMailer.course_unavailable_notification(application_choice, reason).deliver_later
    end
  end
end
