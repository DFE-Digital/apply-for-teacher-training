module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationController < CandidateInterfaceController
      def new
        render_404 unless FeatureFlag.active?(:efl_section)

        @other_qualification_form = EnglishForeignLanguage::OtherEflQualificationForm.new
      end

      def create
        @other_qualification_form = EnglishForeignLanguage::OtherEflQualificationForm.new(other_params)

        if @other_qualification_form.save
          redirect_to candidate_interface_english_foreign_language_review_path
        else
          render :new
        end
      end
    private

      def other_params
        params
          .fetch(:candidate_interface_english_foreign_language_other_efl_qualification_form, {})
          .permit(:name, :grade, :award_year)
          .merge(application_form: current_application)
      end
    end
  end
end
