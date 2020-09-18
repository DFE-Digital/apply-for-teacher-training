module CandidateInterface
  class UnsubmittedApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :redirect_to_application_if_between_cycles, except: %w[show review]
    before_action :redirect_to_carry_over_if_unsubmitted_previous_cycle, except: %w[review]

    def before_you_start; end

    def show
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_form = current_application
    end

    def review
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
      @application_form = current_application
    end

    def submit_show
      @application_form = current_application
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if @application_form_presenter.ready_to_submit?
        @further_information_form = FurtherInformationForm.new
      else
        @errors = @application_form_presenter.section_errors
        @application_choice_errors = @application_form_presenter.application_choice_errors

        render 'candidate_interface/unsubmitted_application_form/review'
      end
    end

    def submit
      @further_information_form = FurtherInformationForm.new(further_information_params)

      if @further_information_form.save(current_application)
        SubmitApplication.new(current_application).call

        redirect_to candidate_interface_application_submit_success_path
      else
        track_validation_error(@further_information_form)
        render :submit_show
      end
    end

  private

    def further_information_params
      params.require(:candidate_interface_further_information_form).permit(
        :further_information,
        :further_information_details,
      )
        .transform_values(&:strip)
    end

    def redirect_to_application_if_between_cycles
      if EndOfCycleTimetable.between_cycles?(current_application.phase)
        flash[:warning] = 'Applications for courses starting this academic year have now closed.'
        redirect_to candidate_interface_application_form_path and return false
      end
      true
    end

    def redirect_to_carry_over_if_unsubmitted_previous_cycle
      if !current_application.submitted? &&
          (
            current_application.recruitment_cycle_year < RecruitmentCycle.current_year ||
            (current_application.recruitment_cycle_year == RecruitmentCycle.current_year && EndOfCycleTimetable.between_cycles_apply_2?)
          )
        redirect_to candidate_interface_start_carry_over_path and return false
      end

      true
    end
  end
end
