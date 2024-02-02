module CandidateInterface
  module References
    class ReviewController < BaseController
      before_action :set_references, only: %i[show complete]
      before_action :set_destroy_backlink, only: %i[confirm_destroy_reference]
      before_action :redirect_to_review_page, unless: -> { @reference }, only: %i[confirm_destroy_reference destroy]

      def show
        @section_complete_form = ReferenceSectionCompleteForm.new(
          completed: current_application.references_completed,
        )
      end

      def complete
        @application_form = current_application
        @section_complete_form = ReferenceSectionCompleteForm.new(
          application_form_params.merge(application_form: @application_form),
        )

        if @application_form.complete_references_information? && @section_complete_form.save(current_application, :references_completed)
          redirect_to candidate_interface_continuous_applications_details_path
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

      def confirm_destroy_reference; end

      def destroy
        DeleteReference.new.call(reference: @reference)

        VerifyAndMarkReferencesIncomplete.new(current_application).call

        redirect_to_review_page
      end

      def destroy_reference_path
        candidate_interface_destroy_new_reference_path(@reference)
      end
      helper_method :destroy_reference_path

    private

      def redirect_to_review_page
        redirect_to candidate_interface_references_review_path
      end

      def set_references
        @references = current_application.application_references.includes(:application_form)
      end

      def set_destroy_backlink
        @destroy_backlink = candidate_interface_references_review_path
      end

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_reference_section_complete_form, {}).permit(:completed)
      end
    end
  end
end
