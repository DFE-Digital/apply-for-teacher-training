module CandidateInterface
  module DecoupledReferences
    class EmailAddressController < BaseController
      before_action :set_reference

      def new
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new
      end

      def create
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(email_address: referee_email_address_param)
        return render :new unless @reference_email_address_form.valid?

        @reference_email_address_form.save(@reference)

        redirect_to candidate_interface_decoupled_references_new_description_path(@reference.id)
      end

    private

      def referee_email_address_param
        params.dig(:candidate_interface_reference_referee_email_address_form, :email_address)
      end
    end
  end
end
