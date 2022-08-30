module AcceptOfferNewReferencesPath
  extend ActiveSupport::Concern

  included do
    helper_method :references_relationship_path
    helper_method :edit_relationship_path
  end

  def references_relationship_path
    candidate_interface_accept_offer_new_references_relationship_path(
      application_choice,
      @reference.id,
    )
  end

  def edit_relationship_path
    candidate_interface_accept_offer_new_references_edit_relationship_path(
      application_choice,
      @reference.id,
      return_to: params[:return_to],
    )
  end
end
