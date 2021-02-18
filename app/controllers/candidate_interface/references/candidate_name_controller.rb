module CandidateInterface
  module References
    class CandidateNameController < BaseController
      before_action :redirect_to_review_page_unless_reference_is_editable

      def new
        @reference_candidate_name_form =
          Reference::CandidateNameForm.build_from_reference(@reference)
      end

      def create
        @reference_candidate_name_form = Reference::CandidateNameForm.new(name_params)

        if @reference_candidate_name_form.save(@reference)
          RequestReference.new.call(@reference)
          flash[:success] = "Reference request sent to #{@reference.name}"
          redirect_to candidate_interface_references_review_path
        else
          track_validation_error(@reference_candidate_name_form)
          render :new
        end
      end

    private

      def name_params
        strip_whitespace params
          .require(:candidate_interface_reference_candidate_name_form)
          .permit(:first_name, :last_name)
      end
    end
  end
end
