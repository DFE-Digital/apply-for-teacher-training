class SupportInterface::Candidates::CourseRecommendationsController < SupportInterface::SupportInterfaceController
  def show
    candidate = Candidate.find(params.expect(:candidate_id))
    application_form = candidate.current_application
    recommendation = CandidateCoursesRecommender.recommended_courses_url(candidate:, locatable: application_form)

    if recommendation.present?
      redirect_to recommendation, allow_other_host: true
    else
      redirect_to support_interface_root_path, notice: 'We are unable to recommend a course for this candidate.'
    end
  end
end
