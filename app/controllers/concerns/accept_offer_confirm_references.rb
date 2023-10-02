module AcceptOfferConfirmReferences
  extend ActiveSupport::Concern

  included do
    skip_before_action :redirect_to_dashboard_if_submitted
    skip_before_action :redirect_to_review_page_unless_reference_is_editable, raise: false
    skip_before_action :verify_authorized_section
    skip_before_action :redirect_to_post_offer_dashboard_if_accepted_or_recruited
    before_action :application_choice
    before_action :check_that_candidate_can_accept
    before_action :check_that_candidate_has_an_offer
  end

  def return_to_path
    candidate_interface_accept_offer_path(application_choice) if params[:return_to] == 'accept-offer'
  end

  def application_choice
    @application_choice ||= @current_application.application_choices.find(params[:application_id])
  end
end
