module CandidateInterface
  module References
    class TypeController < BaseController
      before_action :verify_type_is_editable, only: %i[new create]
      before_action :redirect_to_review_page_unless_reference_is_editable, :set_edit_backlink, only: %i[edit update]

      def new
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: params[:referee_type])
      end

      def edit
        @reference_type_form = Reference::RefereeTypeForm.build_from_reference(@reference)
      end

      def create
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)

        if @reference_type_form.valid?
          redirect_to next_path
        else
          track_validation_error(@reference_type_form)
          render :new
        end
      end

      def update
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)

        if @reference_type_form.update(@reference)
          next_step
        else
          track_validation_error(@reference_type_form)
          render :edit
        end
      end

    private

      def next_path
        candidate_interface_references_name_path(@reference_type_form.referee_type, params[:id])
      end

      def referee_type_param
        params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
      end

      def verify_type_is_editable
        policy = CandidateInterface::ApplicationReferencePolicy.new(@current_candidate, @reference)
        return if @reference.blank? || (@reference.present? && policy.edit?)

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
