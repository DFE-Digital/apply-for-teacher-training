module CandidateInterface
  module EnglishForeignLanguage
    class ToeflController < CandidateInterfaceController
      include EflRootConcern

      def new
        @toefl_form = EnglishForeignLanguage::ToeflForm.new(toefl_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)
      end

      def create
        @toefl_form = EnglishForeignLanguage::ToeflForm.new(toefl_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @toefl_form.save
          redirect_to candidate_interface_english_foreign_language_review_path(@return_to[:params])
        else
          track_validation_error(@toefl_form)
          render :new
        end
      end

      def edit
        toefl = ToeflQualification.where(id: current_application.english_proficiency&.efl_qualification_id).first
        redirect_to_efl_root and return unless toefl

        @toefl_form = EnglishForeignLanguage::ToeflForm.new.fill(toefl: toefl)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)
      end

      def update
        @toefl_form = EnglishForeignLanguage::ToeflForm.new(toefl_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @toefl_form.save
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@toefl_form)
          render :edit
        end
      end

    private

      def toefl_params
        strip_whitespace params
          .fetch(:candidate_interface_english_foreign_language_toefl_form, {})
          .permit(:registration_number, :total_score, :award_year)
          .merge(application_form: current_application)
      end
    end
  end
end
