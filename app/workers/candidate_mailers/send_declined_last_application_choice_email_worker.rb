class CandidateMailers::SendDeclinedLastApplicationChoiceEmailWorker
  include Sidekiq::Worker

  def perform(application_choice_id)
    application_choice = ApplicationChoice.find(application_choice_id)

    recommended_courses_url = CandidateCoursesRecommender.recommended_courses_url(
      candidate: application_choice.candidate,
      locatable: application_choice.current_provider,
    )

    CandidateMailer.decline_last_application_choice(application_choice, recommended_courses_url).deliver_later
  end
end
