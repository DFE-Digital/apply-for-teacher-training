module CandidateInterface
  module DecoupledReferences
    class TypeController < BaseController
      before_action :set_reference, only: %i[edit update]

      def new
        @reference_type_form = Reference::RefereeTypeForm.new
      end

      def create
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)
        return render :new unless @reference_type_form.valid?

        @reference_type_form.save(current_application)

        redirect_to candidate_interface_decoupled_references_name_path(current_application.application_references.last.id)
      end

      def edit
        @reference_type_form = Reference::RefereeTypeForm.build_from_reference(@reference)
      end

      def update
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)
        return render :edit unless @reference_type_form.valid?

        @reference_type_form.update(@reference)

        if return_to_path.present?
          redirect_to return_to_path
        else
          redirect_to candidate_interface_decoupled_references_review_unsubmitted_path(@reference.id)
        end
      end

    private

      def referee_type_param
        params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
      end
    end
  end
end
