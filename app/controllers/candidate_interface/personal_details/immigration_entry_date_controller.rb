module CandidateInterface
  module PersonalDetails
    class ImmigrationEntryDateController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @form = ImmigrationEntryDateForm.build_from_application(current_application)
      end

      def create
        @form = ImmigrationEntryDateForm.new(create_params)

        if @form.save(current_application)
          if LanguagesSectionPolicy.hide?(current_application)
            redirect_to candidate_interface_personal_details_show_path
          else
            redirect_to candidate_interface_languages_path
          end
        else
          track_validation_error(@form)
          render :new
        end
      end

    private

      def create_params
        strip_whitespace(
          params.require(
            :candidate_interface_immigration_entry_date_form,
          ).permit(
            :'immigration_entry_date(3i)',
            :'immigration_entry_date(2i)',
            :'immigration_entry_date(1i)',
          ).transform_keys { |key| date_field_to_attribute(key) },
        )
      end

      def date_field_to_attribute(key)
        case key
        when 'immigration_entry_date(3i)' then 'day'
        when 'immigration_entry_date(2i)' then 'month'
        when 'immigration_entry_date(1i)' then 'year'
        else key
        end
      end
    end
  end
end
