module CandidateInterface
  module References
    class RetryRequestController < BaseController
      def new
        render_404 and return unless can_retry?

        @reference_email_address_form = Reference::RefereeEmailAddressForm.build_from_reference(@reference)
      end

      def create
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(retry_params)
        if @reference_email_address_form.valid?
          ActiveRecord::Base.transaction do
            @reference_email_address_form.save(@reference)
            RequestReference.new.call(@reference)
            flash[:success] = "Reference request sent to #{@reference.name}"
          end
          redirect_to candidate_interface_references_review_path
        else
          render :new
        end
      end

    private

      def can_retry?
        @reference.email_bounced? &&
          CandidateInterface::Reference::SubmitRefereeForm.new(
            submit: 'yes',
            reference_id: @reference.id,
          ).valid?
      end

      def retry_params
        strip_whitespace params
          .require(:candidate_interface_reference_referee_email_address_form).permit(:email_address)
          .merge!(reference_id: @reference.id)
      end
    end
  end
end
