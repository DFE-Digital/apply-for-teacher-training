module CandidateInterface
  module NewReferences
    class EmailAddressController < BaseController
      before_action :redirect_to_review_page_unless_reference_is_editable, :verify_email_is_editable
      before_action :set_edit_backlink, only: %i[edit update]

      def new
        @reference_email_address_form = Reference::RefereeEmailAddressForm.build_from_reference(@reference)
      end

      def create
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(referee_email_address_param)

        if @reference_email_address_form.save(@reference)
          redirect_to candidate_interface_new_references_relationship_path(@reference.id)
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
          next_step
        else
          track_validation_error(@reference_email_address_form)
          render :edit
        end
      end

    private

      def referee_email_address_param
        strip_whitespace(params)
          .require(:candidate_interface_reference_referee_email_address_form).permit(:email_address)
          .merge!(reference_id: @reference.id)
      end

      def verify_email_is_editable
        policy = ReferenceActionsPolicy.new(@reference)
        return if policy.editable? || @reference.email_bounced?

        redirect_to candidate_interface_new_references_review_path
      end
    end
  end
end
