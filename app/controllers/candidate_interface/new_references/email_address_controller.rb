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
          redirect_to next_path
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

      def references_email_address_path
        candidate_interface_new_references_email_address_path(@reference.id)
      end
      helper_method :references_email_address_path

      def edit_email_address_path
        candidate_interface_new_references_edit_email_address_path(@reference.id, return_to: params[:return_to])
      end
      helper_method :edit_email_address_path

      def previous_path
        candidate_interface_new_references_name_path(@reference.referee_type.dasherize, @reference.id)
      end
      helper_method :previous_path

    private

      def next_path
        candidate_interface_new_references_relationship_path(@reference.id)
      end

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
