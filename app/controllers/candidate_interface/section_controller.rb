module CandidateInterface
  class SectionController < CandidateInterfaceController
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
      # unless @section_policy.can_edit?
      #   Rails.logger.info("Not authorized for controller '#{@section_policy.controller_path}' and action '#{@section_policy.action_name}'")
      #   redirect_to candidate_interface_details_path
      # end
    end

    def verify_delete_authorized_section
      redirect_to candidate_interface_details_path unless @section_policy.can_delete?
    end
  end
end
