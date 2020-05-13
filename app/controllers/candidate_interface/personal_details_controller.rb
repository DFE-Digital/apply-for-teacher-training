module CandidateInterface
  class PersonalDetailsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_application_form_to_current_application

    def edit
      @personal_details_form = PersonalDetailsForm.build_from_application(@application_form)
    end

    def update
      @personal_details_form = PersonalDetailsForm.new(personal_details_params)
      @personal_details_review = PersonalDetailsReviewPresenter.new(form: @personal_details_form)

      if @personal_details_form.save(current_application)
        @application_form.update!(personal_details_completed: false)

        render :show
      else
        track_validation_error(@personal_details_form)
        render :edit
      end
    end

    def show
      personal_details_form = PersonalDetailsForm.build_from_application(@application_form)
      @personal_details_review = PersonalDetailsReviewPresenter.new(form: personal_details_form)
    end

    def complete
      if PersonalDetailsForm.build_from_application(@application_form).valid?
        @application_form.update!(application_form_params)

        redirect_to candidate_interface_application_form_path
      else
        flash[:warning] = 'You can’t mark this section as complete without adding all your personal details.'

        @application_form.personal_details_completed = false

        personal_details_form = PersonalDetailsForm.build_from_application(@application_form)
        @personal_details_review = PersonalDetailsReviewPresenter.new(form: personal_details_form)

        render :show
      end
    end

  private

    def set_application_form_to_current_application
      @application_form = current_application
    end

    def personal_details_params
      params.require(:candidate_interface_personal_details_form).permit(
        :first_name, :last_name,
        :"date_of_birth(3i)", :"date_of_birth(2i)", :"date_of_birth(1i)",
        :first_nationality, :second_nationality,
        :english_main_language,
        :english_language_details, :other_language_details
      )
        .transform_keys { |key| dob_field_to_attribute(key) }
        .transform_values(&:strip)
    end

    def application_form_params
      params.require(:application_form).permit(:personal_details_completed)
        .transform_values(&:strip)
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
