class SupportInterface::ApplicationChoices::CourseRecommendationsController < SupportInterface::SupportInterfaceController
  def show
    redirect_to support_interface_root_path, notice: 'We are unable to recommend a course for this application choice.'
  end
end
