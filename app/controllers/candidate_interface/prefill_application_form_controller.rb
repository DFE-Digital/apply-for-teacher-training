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
          return redirect_to candidate_interface_application_choices_path
        end

        redirect_to candidate_interface_details_path
      else
        track_validation_error(@prefill_application_or_not_form)
        render :new
      end
    end

  private

    def redirect_if_application_form_present
      application_form = current_candidate.application_forms.first
      return if application_form.nil? || application_form.blank_application?

      redirect_to candidate_interface_details_path
    end

    def prefill_candidate_application_form
      example_application_choices = factory.create_application(**test_application_options)

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
      {
        recruitment_cycle_year: @current_timetable.recruitment_cycle_year,
        states: [:unsubmitted_with_completed_references],
        courses_to_apply_to: Course.current_cycle.joins(:course_options).merge(CourseOption.available),
        candidate: current_candidate,
      }.tap do |options|
        store = PrefillApplicationStateStore::RailsCache.new(current_candidate.id)

        if (data = store.read)
          course_from_find = Course.find(data[:course_id])
          options[:courses_to_apply_to] = [course_from_find]
          store.clear
        end
      end
    end

    def factory
      TestApplications.new
    end
  end
end
