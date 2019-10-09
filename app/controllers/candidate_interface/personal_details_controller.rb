module CandidateInterface
  class PersonalDetailsController < CandidateInterfaceController
    def edit
      @personal_details_form = PersonalDetailsForm.new
    end

    def update
      @personal_details_form = PersonalDetailsForm.new(personal_details_params)

      render :show
    end

  private

    def personal_details_params
      params.require(:candidate_interface_personal_details_form).permit(
        :first_name, :last_name, :"date_of_birth(3i)", :"date_of_birth(2i)",
        :"date_of_birth(1i)", :nationality, :english_main_language
      )
        .transform_keys { |key| dob_field_to_attribute(key) }
    end

    def dob_field_to_attribute(key)
      case key
      when 'date_of_birth(3i)' then 'day'
      when 'date_of_birth(2i)' then 'month'
      when 'date_of_birth(1i)' then 'year'
      else key
      end
    end
  end
end
