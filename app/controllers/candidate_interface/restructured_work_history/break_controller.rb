module CandidateInterface
  class RestructuredWorkHistory::BreakController < RestructuredWorkHistory::BaseController
    def new
      @work_break = RestructuredWorkHistory::WorkHistoryBreakForm.build_from_date_params(date_params)
    end

    def create
      @work_break = RestructuredWorkHistory::WorkHistoryBreakForm.new(work_history_break_params)

      if @work_break.save(current_application)
        redirect_to candidate_interface_restructured_work_history_review_path
      else
        track_validation_error(@work_break)
        render :new
      end
    end

    def edit
      @work_break = RestructuredWorkHistory::WorkHistoryBreakForm.build_from_break(current_work_history_break)
    end

    def update
      @work_break = RestructuredWorkHistory::WorkHistoryBreakForm.new(work_history_break_params)

      if @work_break.update(current_work_history_break)
        redirect_to candidate_interface_restructured_work_history_review_path
      else
        track_validation_error(@work_break)
        render :edit
      end
    end

    def confirm_destroy
      @work_break = current_work_history_break
    end

    def destroy
      current_work_history_break.destroy!

      if current_application.application_work_experiences.present? || current_application.application_work_history_breaks.present?
        redirect_to candidate_interface_restructured_work_history_review_path
      else
        redirect_to candidate_interface_restructured_work_history_path
      end
    end

  private

    def current_work_history_break
      current_application.application_work_history_breaks.find(current_work_history_break_id)
    end

    def current_work_history_break_id
      params.permit(:id)[:id]
    end

    def work_history_break_params
      strip_whitespace(
        params.require(:candidate_interface_restructured_work_history_work_history_break_form)
        .permit(
          :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)", :reason
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) },
      )
    end

    def date_params
      {
        start_date: params[:start_date],
        end_date: params[:end_date],
      }
    end
  end
end
