class SupportInterface::ApplicationChoices::CourseRecommendationsController < SupportInterface::SupportInterfaceController
  def show
    application_choice = ApplicationChoice.find(params.expect(:application_choice_id))
    provider = application_choice.provider
    candidate = application_choice.candidate

    recommendation = CandidateCoursesRecommender.recommended_courses_url(candidate:, locatable: provider)

    if recommendation.present?
      redirect_to recommendation, allow_other_host: true
    else
      redirect_to support_interface_root_path, notice: 'We are unable to recommend a course for this application choice.'
    end
  end
end
