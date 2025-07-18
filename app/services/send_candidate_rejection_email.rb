class SendCandidateRejectionEmail
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    recommended_courses_url = CandidateCoursesRecommender.recommended_courses_url(
      candidate: application_choice.candidate,
      locatable: application_choice.course.provider,
    )
    CandidateMailer.application_rejected(application_choice, recommended_courses_url).deliver_later
  end
end
