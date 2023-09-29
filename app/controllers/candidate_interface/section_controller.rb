module CandidateInterface
  class SectionController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_or_recruited, if: :continuous_applications?
    before_action :set_section_policy
    before_action :verify_authorized_section, except: %i[show review]

    def show; end
    def review; end

    def set_section_policy
      @section_policy = SectionPolicy.new(
        current_application:,
        controller_path:,
        action_name:,
        params:,
      )
    end

    def verify_authorized_section
      unless @section_policy.can_edit?
        Rails.logger.info("Not authorized for controller '#{@section_policy.controller_path}' and action '#{@section_policy.action_name}'")
        redirect_to candidate_interface_continuous_applications_details_path
      end
    end
  end
end
