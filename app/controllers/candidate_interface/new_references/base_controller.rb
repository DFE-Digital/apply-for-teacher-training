module CandidateInterface
  module NewReferences
    class BaseController < CandidateInterfaceController
      before_action :render_application_feedback_component, :set_reference
      before_action :redirect_to_dashboard_if_submitted


    private

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end

      def return_to_path
        candidate_interface_new_references_review_path if params[:return_to] == 'review'
      end

      def redirect_to_review_page_unless_reference_is_editable
        policy = ReferenceActionsPolicy.new(@reference)

        redirect_to candidate_interface_new_references_review_path if @reference.blank? || !policy.editable?
      end

      def set_edit_backlink
        @edit_backlink = return_to_path || candidate_interface_new_references_review_unsubmitted_path(@reference.id)
      end
    end
  end
end
