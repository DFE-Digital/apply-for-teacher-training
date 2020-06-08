class SendCourseFullNotificationsWorker
  include Sidekiq::Worker

  def perform
    GetApplicationChoicesWithNewlyUnavailableCourses.call.each do |application_choice|
      CandidateMailer.course_unavailable_notification(application_choice, :course_full).deliver_later
    end
  end
end
