module CandidateInterface
  class WorkHistory::EditController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      @work_experience_form = WorkExperienceForm.new
    end

    def create
      @work_experience_form = WorkExperienceForm.new(work_experience_form_params)

      if @work_experience_form.save(current_application)
        redirect_to candidate_interface_work_history_show_path
      else
        render :new
      end
    end

    def edit
      work_experience = current_application
        .application_work_experiences.find(work_experience_params[:id])
      @work_experience_form = WorkExperienceForm.build_from_experience(work_experience)
    end

    def update
      work_experience = current_application
        .application_work_experiences
        .find(work_experience_params[:id])
      @work_experience_form = WorkExperienceForm.new(work_experience_form_params)

      if @work_experience_form.update(work_experience)
        redirect_to candidate_interface_work_history_show_path
      else
        render :edit
      end
    end

  private

    def work_experience_form_params
      params.require(:candidate_interface_work_experience_form)
        .permit(
          :role, :organisation, :details, :working_with_children, :commitment,
          :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)"
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) }
          .transform_values(&:strip)
    end

    def work_experience_params
      params.permit(:id)
    end

    def start_date_field_to_attribute(key)
      case key
      when 'start_date(3i)' then 'start_date_day'
      when 'start_date(2i)' then 'start_date_month'
      when 'start_date(1i)' then 'start_date_year'
      else key
      end
    end

    def end_date_field_to_attribute(key)
      case key
      when 'end_date(3i)' then 'end_date_day'
      when 'end_date(2i)' then 'end_date_month'
      when 'end_date(1i)' then 'end_date_year'
      else key
      end
    end
  end
end
