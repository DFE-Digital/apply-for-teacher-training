module CandidateInterface
  module References
    class BaseController < CandidateInterfaceController
      before_action :render_application_feedback_component, :set_reference

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
        redirect_to candidate_interface_references_review_path unless @reference.present? && policy.editable?
      end
    end
  end
end
