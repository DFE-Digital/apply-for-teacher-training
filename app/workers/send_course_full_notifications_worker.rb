class SendCourseFullNotificationsWorker
  include Sidekiq::Worker

  def perform
    GetApplicationChoicesWithNewlyUnavailableCourses.call.each do |application_choice|
      reason = ReasonCourseNotAvailable.new(application_choice).call
      ChaserSent.create!(
        chased: application_choice,
        chaser_type: :course_unavailable_notification,
      )
      CandidateMailer.course_unavailable_notification(application_choice, reason).deliver_later
      send_slack_message(application_choice, reason)
    end
  end

private

  def send_slack_message(application_choice, reason)
    return if ChaserSent.find_by(
      chased: application_choice,
      chaser_type: :course_unavailable_slack_notification,
    ).present?

    ChaserSent.create!(
      chased: application_choice,
      chaser_type: :course_unavailable_slack_notification,
    )
    message = I18n.t!(
      "candidate_mailer.course_unavailable_notification.slack_message.#{reason}",
      course_name: application_choice.course_option.course.name_and_code,
      provider_name: application_choice.course_option.course.provider.name,
      study_mode: application_choice.course_option.study_mode.humanize.downcase,
      location: application_choice.course_option.site.name,
      candidate_name: application_choice.application_form.first_name,
    )
    url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_choice.application_form)

    SlackNotificationWorker.perform_async(message, url)
  end
end
