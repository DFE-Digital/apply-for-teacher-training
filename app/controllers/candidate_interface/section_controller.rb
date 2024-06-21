module CandidateInterface
  class SectionController < CandidateInterfaceController
    before_action :set_reference_process

    before_action UnsuccessfulCarryOverFilter
    before_action CarryOverFilter
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action :set_section_policy
    before_action :verify_edit_authorized_section, except: %i[show review]
    before_action :verify_delete_authorized_section, only: %i[destroy confirm_destroy]

    def show; end
    def review; end
    def destroy; end
    def confirm_destroy; end

    def set_section_policy
      @section_policy = SectionPolicy.new(
        current_application:,
        controller_path:,
        action_name:,
        params:,
      )
    end

    def verify_edit_authorized_section
      unless @section_policy.can_edit?
        Rails.logger.info("Not authorized for controller '#{@section_policy.controller_path}' and action '#{@section_policy.action_name}'")
        redirect_to candidate_interface_continuous_applications_details_path
      end
    end

    def verify_delete_authorized_section
      redirect_to candidate_interface_continuous_applications_details_path unless @section_policy.can_delete?
    end

  private

    def set_reference_process
      @reference_process = params[:reference_process] || reference_process_from_url
      ### can this minimise the reference-process param passed around?
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
  end
end
