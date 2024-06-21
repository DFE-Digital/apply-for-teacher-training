module CandidateInterface
  module References
    class BaseController < SectionController
      before_action :render_application_feedback_component, :set_reference
      before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
      rescue_from ActiveRecord::RecordNotFound, with: :render_404

    private

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end

      def redirect_to_review_page_unless_reference_is_editable
        policy = ReferenceActionsPolicy.new(@reference)

        redirect_to candidate_interface_references_review_path if @reference.blank? || !policy.editable?
      end
    end
  end
end
