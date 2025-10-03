module CandidateInterface
  class ShareDetailsController < CandidateInterfaceController
    before_action :redirect_to_root_path_if_submitted_applications

    def index; end

  private

    def redirect_to_root_path_if_submitted_applications
      redirect_to root_path unless current_application.submitted_applications?
    end
  end
end
