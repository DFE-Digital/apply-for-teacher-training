module CandidateInterface
  class Volunteering::BaseController < SectionController


  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end
  end
end
