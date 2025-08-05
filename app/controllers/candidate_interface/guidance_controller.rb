module CandidateInterface
  class GuidanceController < CandidateInterfaceController
    skip_before_action :require_authentication
    skip_before_action :authenticate_candidate!
    before_action :set_back_link

    def index
      @recruitment_cycle_year = current_timetable.recruitment_cycle_year
    end

  private

    def set_back_link
      @back_link = if current_candidate
                     request.referer || application_form_path
                   end
    end
  end
end
