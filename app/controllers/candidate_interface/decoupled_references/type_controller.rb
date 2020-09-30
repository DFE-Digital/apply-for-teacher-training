module CandidateInterface
  module DecoupledReferences
    class TypeController < BaseController
      def new
        @reference_type_form = Reference::RefereeTypeForm.new
      end

      def create
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)
        return render :new unless @reference_type_form.valid?

        @reference_type_form.save(current_application)

        redirect_to candidate_interface_decoupled_references_new_name_path(current_application.application_references.last.id)
      end

    private

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end

      def referee_type_param
        params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
      end
    end
  end
end
