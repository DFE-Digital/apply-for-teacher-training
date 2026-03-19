module CandidateInterface
  module EnglishProficiencies
    class NoQualificationDetailsController < SectionController
      before_action :set_return_to

      def new
        @no_qualification_details_form = CandidateInterface::EnglishProficiencies::NoQualificationDetailsForm.new(
          no_qualification_details_params,
        ).fill
      end

      def create
        @no_qualification_details_form = CandidateInterface::EnglishProficiencies::NoQualificationDetailsForm.new(
          no_qualification_details_params,
        )
        if @no_qualification_details_form.save
          redirect_to @no_qualification_details_form.next_path
        else
          track_validation_error(@no_qualification_details_form)
          render :new
        end
      end

    private

      def english_proficiency
        @english_proficiency ||= current_application
          .english_proficiencies
          .find(params[:english_proficiency_id])
      end

      def no_qualification_details_params
        strip_whitespace params
          .fetch(:candidate_interface_english_proficiencies_no_qualification_details_form, {})
          .permit(:declare_no_qualification_details, :no_qualification_details)
          .merge(application_form: current_application, english_proficiency:)
          .merge(return_to: params[:'return-to'])
      end

      def set_return_to
        return_path = if params[:return_to] == 'review'
                        candidate_interface_english_proficiencies_review_path
                      else
                        candidate_interface_english_proficiencies_edit_start_path(english_proficiency)
                      end
        @return_to = return_to_after_edit(default: return_path)
      end
    end
  end
end
