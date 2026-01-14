module CandidateInterface
  module References
    class NameController < BaseController
      before_action :verify_name_is_editable, only: %i[new create]
      before_action :redirect_to_review_page_unless_reference_is_editable, :set_edit_backlink, only: %i[edit update]
      skip_before_action :verify_edit_authorized_section, only: %i[edit update]
      skip_before_action :verify_delete_authorized_section, only: %i[edit update]

      def new
        @reference_name_form = Reference::RefereeNameForm.build_from_reference(@reference)
      end

      def edit
        @reference_name_form = Reference::RefereeNameForm.build_from_reference(@reference)
      end

      def create
        @reference_name_form = Reference::RefereeNameForm.new(referee_name_param)

        if @reference_name_form.save(current_application, params[:referee_type], reference: @reference)
          redirect_to next_path
        else
          track_validation_error(@reference_name_form)
          render :new
        end
      end

      def update
        @reference_name_form = Reference::RefereeNameForm.new(referee_name_param)

        if @reference_name_form.update(@reference)
          next_step
        else
          track_validation_error(@reference_name_form)
          render :edit
        end
      end

    private

      def next_path
        candidate_interface_references_email_address_path(
          @reference&.id || current_application.application_references.creation_order.last.id,
        )
      end

      def referee_name_param
        strip_whitespace params.expect(candidate_interface_reference_referee_name_form: [:name])
      end

      def verify_name_is_editable
        policy = CandidateInterface::ApplicationReferencePolicy.new(@current_candidate, @reference)
        return if @reference.blank? || (@reference.present? && policy.edit?)

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
