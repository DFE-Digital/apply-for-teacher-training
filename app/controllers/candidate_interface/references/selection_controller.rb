module CandidateInterface
  module References
    class SelectionController < BaseController
      def new
        @selection_form = CandidateInterface::Reference::SelectionForm.new(
          application_form: current_application,
          selected: current_application.application_references.selected.pluck(:id),
        )
      end

      def create
        @selection_form = CandidateInterface::Reference::SelectionForm.new(selection_params)
        if @selection_form.save!
          redirect_to candidate_interface_references_review_path
        else
          render :new
        end
      end

    private

      def selection_params
        params.require(:candidate_interface_reference_selection_form).permit(selected: [])
          .merge(application_form: current_application)
      end
    end
  end
end
