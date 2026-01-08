module CandidateInterface
  module References
    class EmailAddressController < BaseController
      before_action :redirect_to_review_page_unless_reference_is_editable, :verify_email_is_editable
      before_action :set_edit_backlink, only: %i[edit update]
      before_action :set_email_address_form, only: %i[create update]

      def new
        @reference_email_address_form = Reference::RefereeEmailAddressForm.build_from_reference(@reference)
      end

      def edit
        @reference_email_address_form = Reference::RefereeEmailAddressForm.build_from_reference(@reference)
      end

      def create
        if @reference_email_address_form.save(@reference)
          redirect_to next_path
        else
          track_validation_error(@reference_email_address_form)
          render :new
        end
      end

      def update
        if @reference_email_address_form.save(@reference)
          redirect_to next_path
        else
          track_validation_error(@reference_email_address_form)
          render :edit
        end
      end

    private

      def next_path
        if @reference_email_address_form.show_interruption?(@reference)
          return_to_params = return_to_review? ? { return_to: 'review' } : nil
          candidate_interface_references_personal_email_address_interruption_path(@reference.id, params: return_to_params)
        else
          return_to_path || candidate_interface_references_relationship_path(@reference.id)
        end
      end

      def set_email_address_form
        @reference_email_address_form = Reference::RefereeEmailAddressForm.new(referee_email_address_param)
      end

      def referee_email_address_param
        strip_whitespace(params)
          .require(:candidate_interface_reference_referee_email_address_form).permit(:email_address)
          .merge!(reference_id: @reference.id)
      end

      def verify_email_is_editable
        policy = CandidateInterface::ApplicationReferencePolicy.new(@current_candidate, @reference)
        return if policy.edit? || @reference.email_bounced?

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
