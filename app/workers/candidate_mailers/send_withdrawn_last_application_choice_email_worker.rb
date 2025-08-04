class CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker
  include Sidekiq::Worker

  def perform(application_form_id)
    application_form = ApplicationForm.find(application_form_id)

    recommended_courses_url = CandidateCoursesRecommender.recommended_courses_url(
      candidate: application_form.candidate,
      locatable: application_form,
    )

    CandidateMailer.withdraw_last_application_choice(application_form, recommended_courses_url).deliver_later
  end
end
