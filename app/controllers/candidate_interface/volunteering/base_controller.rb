module CandidateInterface
  class Volunteering::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end
  end
end
