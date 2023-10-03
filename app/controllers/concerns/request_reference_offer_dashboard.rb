module RequestReferenceOfferDashboard
  extend ActiveSupport::Concern

  included do
    skip_before_action :redirect_to_dashboard_if_submitted
    skip_before_action :redirect_to_review_page_unless_reference_is_editable, raise: false
    skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action :redirect_to_completed_dashboard_if_not_accepted
  end

  def return_to_path
    candidate_interface_references_request_reference_review_path(@reference) if params[:return_to] == 'request-reference-review'
  end
end
