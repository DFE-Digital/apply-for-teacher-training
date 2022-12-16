module SupportInterface
  module ApplicationForms
    class NationalitiesController < SupportInterfaceController
      before_action :set_application_form

      def edit
        @nationalities_form = NationalitiesForm.build_from_application(@application_form)
      end

      def update
        @nationalities_form = NationalitiesForm.new(prepare_nationalities_params)

        if @nationalities_form.save(@application_form)
          if british_or_irish?
            redirect_to support_interface_application_form_path(@application_form)
          else
            redirect_to support_interface_application_form_edit_immigration_right_to_work_path
          end
        else
          render :edit
        end
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def prepare_nationalities_params
        nationalities_params
          .merge(nationalities_hash)
      end

      def nationalities_hash
        nationalities_options = nationalities_params[:nationalities]
        nationalities_options ? nationalities_options.compact_blank.index_by(&:downcase) : {}
      end

      def nationalities_params
        StripWhitespace.from_hash params
          .require(:support_interface_application_forms_nationalities_form)
          .permit(
            :first_nationality, :second_nationality, :other_nationality1, :other_nationality2,
            :other_nationality3, :audit_comment, nationalities: []
          )
      end

      def british_or_irish?
        UK_AND_IRISH_NATIONALITIES.intersect?(@application_form.nationalities)
      end
    end
  end
end
