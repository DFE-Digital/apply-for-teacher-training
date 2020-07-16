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
          redirect_to @start_form.next_path
        else
          render :new
        end
      end

    private

      def start_params
        params
          .fetch(:candidate_interface_english_foreign_language_start_form, {})
          .permit(:has_efl_qualification, :no_qualification_details)
          .merge(application_form: current_application)
      end
    end
  end
end
