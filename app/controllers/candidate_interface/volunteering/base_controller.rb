module CandidateInterface
  class Volunteering::BaseController < SectionController
    before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over

  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end
  end
end
