module CandidateInterface
  module EnglishProficiencies
    class IeltsController < CandidateInterfaceController
      def new
        @ielts_form = EnglishProficiencies::IeltsForm.new
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_type_path)
      end

      def create
        @ielts_form = EnglishProficiencies::IeltsForm.new(ielts_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @ielts_form.save
          redirect_to candidate_interface_english_foreign_language_review_path(@return_to[:params])
        else
          track_validation_error(@ielts_form)
          render :new
        end
      end

    private

      def ielts_params
        strip_whitespace params
          .fetch(:candidate_interface_english_proficiencies_ielts_form, {})
          .permit(:trf_number, :band_score, :award_year)
          .merge(application_form: current_application)
      end
    end
  end
end
