module CandidateInterface
  module DecoupledReferences
    class EmailAddressController < BaseController
      before_action :set_reference, :redirect_to_review_page_unless_not_requested_or_email_bounced

      def new
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new
      end

      def create
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(referee_email_address_param)

        if @reference_email_address_form.save(@reference)
          redirect_to candidate_interface_decoupled_references_relationship_path(@reference.id)
        else
          track_validation_error(@reference_email_address_form)
          render :new
        end
      end

      def edit
        @reference_email_address_form = Reference::RefereeEmailAddressForm.build_from_reference(@reference)
      end

      def update
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(referee_email_address_param)

        if @reference_email_address_form.save(@reference)
          if return_to_path.present?
            redirect_to return_to_path
          else
            redirect_to candidate_interface_decoupled_references_review_unsubmitted_path(@reference.id)
          end
        else
          track_validation_error(@reference_email_address_form)
          render :edit
        end
      end

    private

      def referee_email_address_param
        params
          .require(:candidate_interface_reference_referee_email_address_form).permit(:email_address)
          .merge!(reference_id: @reference.id)
      end

      def redirect_to_review_page_unless_not_requested_or_email_bounced
        redirect_to candidate_interface_decoupled_references_review_path unless @reference.not_requested_yet? || @reference.email_bounced?
      end
    end
  end
end
