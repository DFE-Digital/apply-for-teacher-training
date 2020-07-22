module CandidateInterface
  module EnglishForeignLanguage
    class ToeflController < CandidateInterfaceController
      include EflRootConcern

      def new
        render_404 unless FeatureFlag.active?(:efl_section)

        @toefl_form = EnglishForeignLanguage::ToeflForm.new
      end

      def create
        @toefl_form = EnglishForeignLanguage::ToeflForm.new(toefl_params)

        if @toefl_form.save
          redirect_to candidate_interface_english_foreign_language_review_path
        else
          render :new
        end
      end

      def edit
        toefl = ToeflQualification.where(id: current_application.english_proficiency&.efl_qualification_id).first
        redirect_to_efl_root and return unless toefl

        @toefl_form = EnglishForeignLanguage::ToeflForm.new.fill(toefl: toefl)
      end

      def update
        @toefl_form = EnglishForeignLanguage::ToeflForm.new(toefl_params)

        if @toefl_form.save
          redirect_to candidate_interface_english_foreign_language_review_path
        else
          render :new
        end
      end

    private

      def toefl_params
        params
          .fetch(:candidate_interface_english_foreign_language_toefl_form, {})
          .permit(:registration_number, :total_score, :award_year)
          .merge(application_form: current_application)
      end
    end
  end
end
