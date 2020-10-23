module CandidateInterface
  module DecoupledReferences
    class BaseController < CandidateInterfaceController
      def start; end

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
          candidate_interface_decoupled_references_review_path
        end
      end
    end
  end
end
