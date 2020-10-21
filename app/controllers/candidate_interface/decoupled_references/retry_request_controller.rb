module CandidateInterface
  module DecoupledReferences
    class RetryRequestController < BaseController
      before_action :set_reference

      def new
        render_404 and return unless can_retry?

        @request_form = Reference::RefereeEmailAddressForm.build_from_reference(@reference)
      end

      def create
        #TODO: validate presence of email_address?
        #TODO: other validation rules for email_address
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(retry_params)
        if @reference_email_address_form.valid?
          #TODO: txn?
          @reference_email_address_form.save(@reference)
          CandidateInterface::DecoupledReferences::RequestReference.new.call(
            @reference,
            flash,
          )
          redirect_to candidate_interface_decoupled_references_review_path
        else
          # TODO: 
          render :new
        end
      end

    private

      def can_retry?
        @reference.email_bounced? &&
          !@reference.application_form.enough_references_have_been_provided? &&
          CandidateInterface::Reference::SubmitRefereeForm.new(
            submit: 'yes',
            reference_id: @reference.id,
          ).valid?
      end

      def retry_params
        params
          .require(:candidate_interface_reference_referee_email_address_form).permit(:email_address)
          .merge!(reference_id: @reference.id)
      end
    end
  end
end
