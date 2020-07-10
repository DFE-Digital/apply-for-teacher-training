module CandidateInterface
  class Gcse::InstitutionCountryController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
    end
  end
end
