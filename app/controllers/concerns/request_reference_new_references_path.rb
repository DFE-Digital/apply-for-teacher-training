module RequestReferenceNewReferencesPath
  extend ActiveSupport::Concern

  included do
    helper_method :references_email_address_path
    helper_method :edit_email_address_path
    helper_method :references_relationship_path
    helper_method :edit_relationship_path
  end

  def references_email_address_path
    candidate_interface_request_reference_new_references_email_address_path(
      @reference.id,
    )
  end

  def edit_email_address_path
    candidate_interface_request_reference_new_references_edit_email_address_path(
      @reference.id,
      return_to: params[:return_to],
    )
  end

  def references_relationship_path
    candidate_interface_request_reference_new_references_relationship_path(
      @reference.id,
    )
  end

  def edit_relationship_path
    candidate_interface_request_reference_new_references_edit_relationship_path(
      @reference.id,
      return_to: params[:return_to],
    )
  end
end
