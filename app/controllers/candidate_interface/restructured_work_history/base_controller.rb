module CandidateInterface
  class RestructuredWorkHistory::BaseController < SectionController
    before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
  end
end
