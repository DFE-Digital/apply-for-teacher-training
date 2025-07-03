class SupportInterface::ApplicationForms::CourseRecommendationsController < SupportInterface::SupportInterfaceController
  def show
    application_form = ApplicationForm.find(params.expect(:application_form_id))
    recommendation = CandidateCoursesRecommender.recommended_courses_url(candidate: application_form.candidate, locatable: application_form)

    if recommendation.present?
      redirect_to recommendation, allow_other_host: true
    else
      redirect_to support_interface_root_path, notice: 'We are unable to recommend a course for this application form.'
    end
  end
end
