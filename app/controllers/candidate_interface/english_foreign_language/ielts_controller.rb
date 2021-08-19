module CandidateInterface
  module EnglishForeignLanguage
    class IeltsController < CandidateInterfaceController
      include EflRootConcern

      def new
        @ielts_form = EnglishForeignLanguage::IeltsForm.new
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)
      end

      def create
        @ielts_form = EnglishForeignLanguage::IeltsForm.new(ielts_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @ielts_form.save
          redirect_to candidate_interface_english_foreign_language_review_path(@return_to[:params])
        else
          track_validation_error(@ielts_form)
          render :new
        end
      end

      def edit
        ielts = IeltsQualification.where(id: current_application.english_proficiency&.efl_qualification_id).first
        redirect_to_efl_root and return unless ielts

        @ielts_form = EnglishForeignLanguage::IeltsForm.new.fill(ielts: ielts)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)
      end

      def update
        @ielts_form = EnglishForeignLanguage::IeltsForm.new(ielts_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @ielts_form.save
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@ielts_form)
          render :edit
        end
      end

    private

      def ielts_params
        strip_whitespace params
          .fetch(:candidate_interface_english_foreign_language_ielts_form, {})
          .permit(:trf_number, :band_score, :award_year)
          .merge(application_form: current_application)
      end
    end
  end
end
