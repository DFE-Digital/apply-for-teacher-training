module AcceptOfferNewReferencesPath
  extend ActiveSupport::Concern

  included do
    helper_method :reference_edit_name_path
    helper_method :references_type_path
    helper_method :reference_new_type_path
    helper_method :references_name_path
    helper_method :reference_edit_name_path
    helper_method :references_email_address_path
    helper_method :edit_email_address_path
    helper_method :references_relationship_path
    helper_method :edit_relationship_path
  end

  def references_type_path
    candidate_interface_accept_offer_new_references_type_path(
      application_choice,
      params[:referee_type],
      params[:id],
    )
  end

  def reference_new_type_path
    candidate_interface_accept_offer_new_references_type_path(
      application_choice,
      params[:referee_type],
      params[:id],
    )
  end

  def reference_edit_type_path
    candidate_interface_accept_offer_new_references_edit_type_path(
      application_choice,
      @reference.id,
      return_to: params[:return_to],
    )
  end

  def references_name_path
    candidate_interface_accept_offer_new_references_name_path(
      application_choice,
      params[:referee_type],
      params[:id],
    )
  end

  def reference_edit_name_path
    candidate_interface_accept_offer_new_references_edit_name_path(
      application_choice,
      @reference.id,
      return_to: params[:return_to],
    )
  end

  def references_email_address_path
    candidate_interface_accept_offer_new_references_email_address_path(
      application_choice,
      @reference.id,
    )
  end

  def edit_email_address_path
    candidate_interface_accept_offer_new_references_edit_email_address_path(
      application_choice,
      @reference.id,
      return_to: params[:return_to],
    )
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
