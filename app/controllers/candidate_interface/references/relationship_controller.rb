module CandidateInterface
  module References
    class RelationshipController < BaseController
      before_action :redirect_to_review_page_unless_reference_is_editable
      before_action :set_edit_backlink, only: %i[edit update]

      def new
        @references_relationship_form = Reference::RefereeRelationshipForm.new
      end

      def create
        @references_relationship_form = Reference::RefereeRelationshipForm.new(references_relationship_params)

        if @references_relationship_form.save(@reference)
          redirect_to candidate_interface_references_review_unsubmitted_path(@reference.id)
        else
          track_validation_error(@references_relationship_form)
          render :new
        end
      end

      def edit
        @references_relationship_form = Reference::RefereeRelationshipForm.build_from_reference(@reference)
      end

      def update
        @references_relationship_form = Reference::RefereeRelationshipForm.new(references_relationship_params)

        if @references_relationship_form.save(@reference)
          if return_to_path.present?
            redirect_to return_to_path
          else
            redirect_to candidate_interface_references_review_unsubmitted_path(@reference.id)
          end
        else
          track_validation_error(@references_relationship_form)
          render :edit
        end
      end

    private

      def references_relationship_params
        strip_whitespace params.require(:candidate_interface_reference_referee_relationship_form).permit(:relationship)
      end
    end
  end
end
