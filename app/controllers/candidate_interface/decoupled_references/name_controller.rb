module CandidateInterface
  module DecoupledReferences
    class NameController < BaseController
      before_action :set_reference

      def new
        @reference_name_form = Reference::RefereeNameForm.new
      end

      def create
        @reference_name_form = Reference::RefereeNameForm.new(referee_name_param)
        return render :new unless @reference_name_form.valid?

        @reference_name_form.save(@reference)

        redirect_to candidate_interface_decoupled_references_email_address_path(@reference.id)
      end

      def edit
        @reference_name_form = Reference::RefereeNameForm.build_from_reference(@reference)
      end

      def update
        @reference_name_form = Reference::RefereeNameForm.new(referee_name_param)
        return render :edit unless @reference_name_form.valid?

        @reference_name_form.save(@reference)

        if return_to_path.present?
          redirect_to return_to_path
        else
          redirect_to candidate_interface_decoupled_references_review_unsubmitted_path(@reference.id)
        end
      end

    private

      def referee_name_param
        params.require(:candidate_interface_reference_referee_name_form).permit(:name)
      end
    end
  end
end
