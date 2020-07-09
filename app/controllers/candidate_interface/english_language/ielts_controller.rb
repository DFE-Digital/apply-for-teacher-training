module CandidateInterface
  module EnglishLanguage
    class IeltsController < CandidateInterfaceController
      def new
        render_404 unless FeatureFlag.active?(:efl_section)

        @ielts_form = EnglishForeignLanguage::IeltsForm.new
      end

      def create
        @ielts_form = EnglishForeignLanguage::IeltsForm.new(ielts_params)

        if @ielts_form.save
          redirect_to candidate_interface_english_language_review_path
        else
          render :new
        end
      end

    private

      def ielts_params
        params
          .require(:candidate_interface_english_foreign_language_ielts_form)
          .permit(:trf_number, :band_score, :award_year)
      end
    end
  end
end
