module CandidateInterface
  module References
    class BaseController < CandidateInterfaceController
      before_action :render_application_feedback_component, :set_reference
      before_action :redirect_to_dashboard_if_submitted
      before_action :redirect_to_new_references_if_feature_is_enabled

    private

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end

      def return_to_path
        case params[:return_to]&.to_sym
        when :review
          candidate_interface_references_review_path
        end
      end

      def redirect_to_review_page_unless_reference_is_editable
        policy = ReferenceActionsPolicy.new(@reference)
        redirect_to candidate_interface_references_review_path if @reference.blank? || !policy.editable?
      end

      def redirect_to_new_references_if_feature_is_enabled
        redirect_to candidate_interface_new_references_review_path if current_application.show_new_reference_flow?
      end

      def set_edit_backlink
        @edit_backlink = return_to_path || candidate_interface_references_review_unsubmitted_path(@reference.id)
      end
    end
  end
end
