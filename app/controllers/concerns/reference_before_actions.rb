module ReferenceBeforeActions
  extend ActiveSupport::Concern

  included do
    skip_before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over, if: -> { request_reference_or_accept_offer? }
    skip_before_action :redirect_to_review_page_unless_reference_is_editable, raise: false, if: -> { request_reference_or_accept_offer? }
    skip_before_action ::UnsuccessfulCarryOverFilter, if: -> { request_reference_or_accept_offer? }
    skip_before_action ::CarryOverFilter, if: -> { request_reference_or_accept_offer? }
    skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited, if: -> { request_reference_or_accept_offer? }
    before_action :redirect_to_completed_dashboard_if_not_accepted_deferred_or_recruited, if: -> { request_refernce? }

    skip_before_action :verify_edit_authorized_section, if: -> { accept_offer? }
    skip_before_action :verify_delete_authorized_section, if: -> { accept_offer? }
    before_action :set_application_choice, if: -> { accept_offer? }
    before_action :check_that_candidate_can_accept, if: -> { accept_offer? }
    before_action :check_that_candidate_has_an_offer, if: -> { accept_offer? }
  end

private

  def request_refernce?
    request_reference == 'request-reference'
  end

  def request_reference_or_accept_offer?
    request_reference == 'request-reference' || request_reference == 'accept-offer'
  end

  def accept_offer?
    request_reference == 'accept-offer'
  end

  def request_reference
    params[:reference_process] || reference_process_from_url
  end

  def reference_process_from_url
    if request.path.include?('candidate-details')
      'candidate-details'
    elsif request.path.include?('accept-reference')
      'accept-offer'
    elsif request.path.include?('request-reference')
      'request-reference'
    end
  end

  def set_application_choice
    @application_choice ||= @current_application.application_choices.find_by(id: params[:application_id])
  end
end
