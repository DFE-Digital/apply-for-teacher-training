module CandidateInterface
  class RestructuredWorkHistory::JobController < RestructuredWorkHistory::BaseController
    def new
      @job_form = RestructuredWorkHistory::JobForm.new
      @return_to = return_to
    end

    def create
      @job_form = RestructuredWorkHistory::JobForm.new(job_form_params)
      @return_to = return_to

      if @job_form.save(current_application)
        return redirect_to return_to[:back_path] if redirect_back_to_application_review_page?

        redirect_to candidate_interface_restructured_work_history_review_path
      else
        track_validation_error(@job_form)
        @job_form.cast_booleans
        render :new
      end
    end

    def edit
      @job_form = RestructuredWorkHistory::JobForm.build_form(job)
      @return_to = return_to
    end

    def update
      @job_form = RestructuredWorkHistory::JobForm.new(job_form_params)
      @return_to = return_to

      if @job_form.update(job)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@job_form)
        @job_form.cast_booleans
        render :edit
      end
    end

    def confirm_destroy
      @job = job
      @return_to = return_to
    end

    def destroy
      job.destroy!
      current_application.application_work_experiences.reload

      if redirect_back_to_application_review_page?
        redirect_to candidate_interface_application_review_path
      elsif current_application.application_work_experiences.blank? && current_application.application_work_history_breaks.present?
        current_application.update!(work_history_completed: nil)
        current_application.application_work_history_breaks.destroy_all
        redirect_to candidate_interface_restructured_work_history_path
      elsif current_application.application_work_experiences.present? || current_application.application_work_history_breaks.present?
        redirect_to candidate_interface_restructured_work_history_review_path
      else
        redirect_to candidate_interface_restructured_work_history_path
      end
    end

  private

    def return_to
      default_path = if current_application.application_work_experiences.present?
                       candidate_interface_restructured_work_history_review_path
                     else
                       candidate_interface_restructured_work_history_path
                     end

      return_to_after_edit(default: default_path)
    end

    def job
      current_application
        .application_work_experiences
        .find(job_params[:id])
    end

    def job_form_params
      strip_whitespace(
        params.require(:candidate_interface_restructured_work_history_job_form)
              .permit(
                :role,
                :organisation,
                :commitment,
                :'start_date(3i)',
                :'start_date(2i)',
                :'start_date(1i)',
                :start_date_unknown,
                :currently_working,
                :'end_date(3i)',
                :'end_date(2i)',
                :'end_date(1i)',
                :end_date_unknown,
                :relevant_skills,
              )
              .transform_keys { |key| start_date_field_to_attribute(key) }
              .transform_keys { |key| end_date_field_to_attribute(key) },
      )
    end

    def job_params
      params.permit(:id)
    end
  end
end
