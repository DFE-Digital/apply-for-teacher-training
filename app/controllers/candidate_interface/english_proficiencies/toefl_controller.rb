module CandidateInterface
  module EnglishProficiencies
    class ToeflController < CandidateInterfaceController
      before_action :set_return_to

      def new
        @toefl_form = EnglishProficiencies::ToeflForm.new(toefl_params).fill
      end

      def create
        @toefl_form = EnglishProficiencies::ToeflForm.new(toefl_params)

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
                           .merge(application_form: current_application, english_proficiency:)
      end

      def english_proficiency
        @english_proficiency ||= current_application
                                   .english_proficiencies
                                   .find(params[:english_proficiency_id])
      end

      def set_return_to
        return_path = if params[:return_to] == 'review'
                        candidate_interface_english_proficiencies_review_path
                      else
                        candidate_interface_english_proficiencies_type_path(english_proficiency, type: 'toefl')
                      end
        @return_to = return_to_after_edit(default: return_path)
      end
    end
  end
end
