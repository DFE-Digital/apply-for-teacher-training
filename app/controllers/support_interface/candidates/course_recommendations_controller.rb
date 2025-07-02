class SupportInterface::Candidates::CourseRecommendationsController < SupportInterface::SupportInterfaceController
  def show
    redirect_to support_interface_root_path, notice: 'We are unable to recommend a course for this candidate.'
  end
end
