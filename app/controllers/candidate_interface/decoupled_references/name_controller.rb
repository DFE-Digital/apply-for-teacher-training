module CandidateInterface
  module DecoupledReferences
    class NameController < BaseController
      before_action :set_reference

      def new
        @reference_name_form = Reference::RefereeNameForm.new
      end

      def create
        @reference_name_form = Reference::RefereeNameForm.new(name: referee_name_param)
        return render :new unless @reference_name_form.valid?

        @reference_name_form.save(@reference)

        redirect_to candidate_interface_decoupled_references_new_email_address_path(@reference.id)
      end

    private

      def referee_name_param
        params.dig(:candidate_interface_reference_referee_name_form, :name)
      end
    end
  end
end
