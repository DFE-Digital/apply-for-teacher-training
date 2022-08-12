module RequestReferenceOfferDashboard
  extend ActiveSupport::Concern

  included do
    skip_before_action :redirect_to_dashboard_if_submitted
    skip_before_action :redirect_to_review_page_unless_reference_is_editable, raise: false
  end

  def return_to_path
    candidate_interface_new_references_request_reference_review_path(@reference) if params[:return_to] == 'request-reference-review'
  end
end
