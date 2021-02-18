module CandidateInterface
  class WorkHistory::EditController < WorkHistory::BaseController
    def new
      @work_experience_form = if params[:start_date] && params[:end_date]
                                start_date = params[:start_date].to_date
                                end_date = params[:end_date].to_date

                                end_date = nil if end_date.month == Time.zone.today.month && end_date.year == Time.zone.today.year

                                WorkExperienceForm.new(
                                  start_date_month: start_date.month,
                                  start_date_year: start_date.year,
                                  end_date_month: end_date&.month || '',
                                  end_date_year: end_date&.year || '',
                                  add_another_job: 'no',
                                )
                              else
                                WorkExperienceForm.new(add_another_job: 'no')
                              end
    end

    def create
      @work_experience_form = WorkExperienceForm.new(work_experience_form_params)

      if @work_experience_form.blank_form?
        redirect_to candidate_interface_work_history_show_path
      elsif @work_experience_form.save(current_application)
        if @work_experience_form.add_another_job == 'yes'
          redirect_to candidate_interface_new_work_history_path
        else
          redirect_to candidate_interface_work_history_show_path
        end
        current_application.update!(work_history_completed: false)
      else
        track_validation_error(@work_experience_form)
        render :new
      end
    end

    def edit
      work_experience = current_application
        .application_work_experiences.find(work_experience_params[:id])
      @work_experience_form = WorkExperienceForm.build_from_experience(work_experience)
      @work_experience_form.add_another_job = 'no'
    end

    def update
      work_experience = current_application
        .application_work_experiences
        .find(work_experience_params[:id])
      @work_experience_form = WorkExperienceForm.new(work_experience_form_params)

      if @work_experience_form.update(work_experience)
        current_application.update!(work_history_completed: false)

        redirect_to candidate_interface_work_history_show_path
      else
        track_validation_error(@work_experience_form)
        render :edit
      end
    end

  private

    def work_experience_form_params
      strip_whitespace(
        params.require(:candidate_interface_work_experience_form)
        .permit(
          :role, :organisation, :details, :working_with_children, :commitment,
          :working_pattern, :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)", :add_another_job
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) },
      )
    end

    def work_experience_params
      params.permit(:id)
    end
  end
end
