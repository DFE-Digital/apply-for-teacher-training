module CandidateInterface
  class PrefillApplicationFormController < CandidateInterfaceController
    before_action :redirect_if_application_form_present

    def new
      @prefill_application_or_not_form = PrefillApplicationOrNotForm.new
    end

    def create
      @prefill_application_or_not_form = PrefillApplicationOrNotForm.new(prefill_application_or_not_params)

      if @prefill_application_or_not_form.valid?
        if @prefill_application_or_not_form.prefill?
          prefill_candidate_application_form
          flash[:info] = 'This application has been prefilled with example data'
          redirect_to candidate_interface_application_form_path
        else
          redirect_to candidate_interface_before_you_start_path
        end
      else
        track_validation_error(@prefill_application_or_not_form)
        render :new
      end
    end

  private

    def redirect_if_application_form_present
      application_form = current_candidate.application_forms.first
      return if application_form.nil? || application_form.blank_application?

      redirect_to candidate_interface_application_form_path
    end

    def prefill_candidate_application_form
      example_application_choices = TestApplications.new.create_application(test_application_options)

      destroy_blank_application

      example_application_form = example_application_choices.first.application_form
      current_candidate.application_forms << example_application_form
    end

    def prefill_application_or_not_params
      params.fetch(:candidate_interface_prefill_application_or_not_form, {}).permit(:prefill)
    end

    def destroy_blank_application
      application_form = current_candidate.application_forms.first
      application_form.destroy if application_form.blank_application?
    end

    def test_application_options
      test_application_options = {
        recruitment_cycle_year: RecruitmentCycle.current_year,
        states: [:unsubmitted_with_completed_references],
        courses_to_apply_to: Course.current_cycle.open_on_apply.joins(:course_options).merge(CourseOption.available),
        candidate: current_candidate,
      }

      store = PrefillApplicationStateStore::RailsCache.new(current_candidate.id)
      data = store.read

      if data
        course_from_find = Course.find(data[:course_id])
        test_application_options.merge!(courses_to_apply_to: [course_from_find])
        store.clear
      end

      test_application_options
    end
  end
end
