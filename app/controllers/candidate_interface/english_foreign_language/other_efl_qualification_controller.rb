module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationController < CandidateInterfaceController
      include EflRootConcern

      def new
        @other_qualification_form = EnglishForeignLanguage::OtherEflQualificationForm.new
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)
      end

      def create
        @other_qualification_form = EnglishForeignLanguage::OtherEflQualificationForm.new(other_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @other_qualification_form.save
          redirect_to candidate_interface_english_foreign_language_review_path(@return_to[:params])
        else
          track_validation_error(@other_qualification_form)
          render :new
        end
      end

      def edit
        other_qualification = OtherEflQualification.where(id: current_application.english_proficiency&.efl_qualification_id).first
        redirect_to_efl_root and return unless other_qualification

        @other_qualification_form = EnglishForeignLanguage::OtherEflQualificationForm.new.fill(qualification: other_qualification)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)
      end

      def update
        @other_qualification_form = EnglishForeignLanguage::OtherEflQualificationForm.new(other_params)
        @return_to = return_to_after_edit(default: candidate_interface_english_foreign_language_review_path)

        if @other_qualification_form.save
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@other_qualification_form)
          render :edit
        end
      end

    private

      def other_params
        strip_whitespace params
          .fetch(:candidate_interface_english_foreign_language_other_efl_qualification_form, {})
          .permit(:name, :grade, :award_year)
          .merge(application_form: current_application)
      end
    end
  end
end
