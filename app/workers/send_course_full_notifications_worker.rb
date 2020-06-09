class SendCourseFullNotificationsWorker
  include Sidekiq::Worker

  def perform
    GetApplicationChoicesWithNewlyUnavailableCourses.call.each do |application_choice|
      reason = reason_course_is_unavailable(application_choice)
      CandidateMailer.course_unavailable_notification(application_choice, reason).deliver_later
    end
  end

  private

  # TODO: Refactor this logic into a separate class?
  def reason_course_is_unavailable(application_choice)
    # all course options for the given course are full
    return :course_full if application_choice.course_full?

    # all course options for the given course are full at the selected location
    return :location_full if application_choice.site_full?

    # TODO: Handle other reasons...
    # :location_withdrawn # n/a?
    # :study_mode_full # all part/full-time course options are full for the given course
    # :study_mode_withdrawn # n/a?
    # :study_mode_location_full # the selected study mode is full at the selected location for the given course but (another study mode is available at the given location)
    # :study_mode_location_withdrawn # n/a?
    # :course_withdrawn # the course has been withdrawn (removing all course options)
  end
end
