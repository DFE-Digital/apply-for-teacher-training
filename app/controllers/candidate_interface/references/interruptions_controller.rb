module CandidateInterface
  module References
    class InterruptionsController < BaseController
      before_action :set_navigation_links

    private

      def set_navigation_links
        @next_step = return_to_path || candidate_interface_references_relationship_path

        return_to_params = return_to_review? ? { return_to: 'review' } : nil
        @back_link = candidate_interface_references_edit_email_address_path(@reference.id, params: return_to_params)
      end
    end
  end
end
