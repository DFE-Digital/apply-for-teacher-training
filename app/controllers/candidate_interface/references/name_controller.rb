module CandidateInterface
  module References
    class NameController < BaseController
      before_action :redirect_to_review_page_unless_reference_is_editable

      def new
        @reference_name_form = Reference::RefereeNameForm.new
      end

      def create
        @reference_name_form = Reference::RefereeNameForm.new(referee_name_param)

        if @reference_name_form.save(@reference)
          redirect_to candidate_interface_references_email_address_path(@reference.id)
        else
          track_validation_error(@reference_name_form)
          render :new
        end
      end

      def edit
        @reference_name_form = Reference::RefereeNameForm.build_from_reference(@reference)
      end

      def update
        @reference_name_form = Reference::RefereeNameForm.new(referee_name_param)

        if @reference_name_form.save(@reference)
          if return_to_path.present?
            redirect_to return_to_path
          else
            redirect_to candidate_interface_references_review_unsubmitted_path(@reference.id)
          end
        else
          track_validation_error(@reference_name_form)
          render :edit
        end
      end

    private

      def referee_name_param
        strip_whitespace params.require(:candidate_interface_reference_referee_name_form).permit(:name)
      end
    end
  end
end
