module CandidateInterface
  module EnglishForeignLanguage
    class StartController < CandidateInterfaceController
      def new
        render_404 unless FeatureFlag.active?(:efl_section)

        @start_form = EnglishForeignLanguage::StartForm.new
      end

      def create
        @start_form = EnglishForeignLanguage::StartForm.new(start_params)

        if @start_form.save
          redirect_to candidate_interface_english_foreign_language_type_path
        else
          render :new
        end
      end

    private

      def start_params
        params
          .require(:candidate_interface_english_foreign_language_start_form)
          .permit(:efl_qualification)
      end
    end
  end
end
