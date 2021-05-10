module CandidateInterface
  module References
    class TypeController < BaseController
      before_action :set_reference, only: %i[edit update]
      before_action :redirect_to_review_page_unless_reference_is_editable, only: %i[edit update]

      def new
        @reference_type_form = Reference::RefereeTypeForm.new
      end

      def create
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)

        if @reference_type_form.valid?
          redirect_to candidate_interface_references_name_path(@reference_type_form.referee_type)
        else
          track_validation_error(@reference_type_form)
          render :new
        end
      end

      def edit
        @reference_type_form = Reference::RefereeTypeForm.build_from_reference(@reference)
      end

      def update
        @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)

        if @reference_type_form.update(@reference)
          if return_to_path.present?
            redirect_to return_to_path
          else
            redirect_to candidate_interface_references_review_unsubmitted_path(@reference.id)
          end
        else
          track_validation_error(@reference_type_form)
          render :edit
        end
      end

    private

      def referee_type_param
        params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
      end
    end
  end
end
