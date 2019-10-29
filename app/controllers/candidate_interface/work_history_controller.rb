module CandidateInterface
  class WorkHistoryController < CandidateInterfaceController
    def length
      @work_details_form = WorkHistoryForm.new
    end

    def submit_length
      @work_details_form = WorkHistoryForm.new(work_history_params)

      if @work_details_form.valid?
        redirect_to candidate_interface_work_history_new_path
      else
        render :length
      end
    end

    def new
      @work_experience_form = WorkExperienceForm.new
    end

    def create
      @work_experience_form = WorkExperienceForm.new(work_experience_params)

      if @work_experience_form.save(current_candidate.current_application)
        redirect_to candidate_interface_work_history_show_path
      else
        render :new
      end
    end

    def show
      @application_form = current_candidate.current_application
    end

    def confirm_destroy
      @work_experience = current_candidate.current_application
        .application_work_experiences.find(destroy_params[:id])
    end

    def destroy
      current_candidate.current_application
        .application_work_experiences
        .find(destroy_params[:id])
        .destroy!

      redirect_to candidate_interface_work_history_show_path
    end

  private

    def work_history_params
      return nil unless params.has_key?(:candidate_interface_work_history_form)

      params.require(:candidate_interface_work_history_form).permit(
        :work_history,
      )
    end

    def work_experience_params
      params.require(:candidate_interface_work_experience_form)
        .permit(
          :role, :organisation, :details, :working_with_children, :commitment,
          :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)"
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) }
          .transform_keys(&:strip)
    end

    def destroy_params
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
