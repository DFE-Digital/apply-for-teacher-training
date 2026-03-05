module CandidateInterface
  module EnglishProficiencies
    class ToeflController < CandidateInterfaceController
      def new
        @toefl_form = EnglishProficiencies::ToeflForm.new(toefl_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_proficiencies_type_path)
      end

      def create
        @toefl_form = EnglishProficiencies::ToeflForm.new(toefl_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @toefl_form.save
          redirect_to candidate_interface_english_foreign_language_review_path(@return_to[:params])
        else
          track_validation_error(@toefl_form)
          render :new
        end
      end

    private

      def toefl_params
        strip_whitespace params
                           .fetch(:candidate_interface_english_proficiencies_toefl_form, {})
                           .permit(:registration_number, :total_score, :award_year)
                           .merge(application_form: current_application)
      end
    end
  end
end
