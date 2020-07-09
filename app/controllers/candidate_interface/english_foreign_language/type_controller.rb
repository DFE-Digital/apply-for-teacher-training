module CandidateInterface
  module EnglishForeignLanguage
    class TypeController < CandidateInterfaceController
      def new
        render_404 unless FeatureFlag.active?(:efl_section)

        @type_form = EnglishForeignLanguage::TypeForm.new
      end

      def create
        @type_form = EnglishForeignLanguage::TypeForm.new(type_params)

        if @type_form.save
          redirect_to @type_form.path_for_next_form
        else
          render :new
        end
      end

    private

      def type_params
        params
          .require(:candidate_interface_english_foreign_language_type_form)
          .permit(:type)
      end
    end
  end
end
