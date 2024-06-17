module RequestReferenceOfferDashboard
  extend ActiveSupport::Concern

  included do
    skip_before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over, if: -> {params[:reference_process] == 'request-reference'}
    skip_before_action :redirect_to_review_page_unless_reference_is_editable, raise: false, if: -> {params[:reference_process] == 'request-reference'}
    skip_before_action ::UnsuccessfulCarryOverFilter, if: -> { params[:reference_process] == 'request-reference' }
    skip_before_action ::CarryOverFilter, if: -> {params[:reference_process] == 'request-reference'}
    skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited, if: -> {params[:reference_process] == 'request-reference'}
    before_action :redirect_to_completed_dashboard_if_not_accepted_deferred_or_recruited, if: -> {params[:reference_process] == 'request-reference'}
  end

  def return_to_path
    candidate_interface_references_request_reference_review_path(@reference) if params[:return_to] == 'request-reference-review'
  end
end
