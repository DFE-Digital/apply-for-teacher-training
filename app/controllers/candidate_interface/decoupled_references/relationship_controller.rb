module CandidateInterface
  module DecoupledReferences
    class RelationshipController < BaseController
      before_action :set_reference

      def new
        @references_relationship_form = Reference::RefereeRelationshipForm.new
      end

      def create
        @references_relationship_form = Reference::RefereeRelationshipForm.new(references_relationship_params)
        return render :new unless @references_relationship_form.valid?

        @references_relationship_form.save(@reference)

        redirect_to candidate_interface_decoupled_references_review_unsubmitted_path(@reference.id)
      end

    private

      def references_relationship_params
        params.require(:candidate_interface_reference_referee_relationship_form).permit(:relationship)
      end
    end
  end
end
