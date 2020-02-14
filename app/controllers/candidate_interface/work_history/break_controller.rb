module CandidateInterface
  class WorkHistory::BreakController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def new
      @work_break = if params[:start_date] && params[:end_date]
                      start_date = params[:start_date].to_date
                      end_date = params[:end_date].to_date

                      WorkHistoryBreakForm.new(
                        start_date_month: start_date.month,
                        start_date_year: start_date.year,
                        end_date_month: end_date.month,
                        end_date_year: end_date.year,
                      )
                    else
                      WorkHistoryBreakForm.new
                    end
    end

    def create
      @work_break = WorkHistoryBreakForm.new(work_history_break_params)

      if @work_break.save(current_application)
        redirect_to candidate_interface_work_history_show_path
      else
        render :new
      end
    end

    def confirm_destroy
      @work_break = current_work_history_break
    end

    def destroy
      current_work_history_break.destroy!

      redirect_to candidate_interface_work_history_show_path
    end

  private

    def current_work_history_break
      current_application.application_work_history_breaks.find(current_work_history_break_id)
    end

    def current_work_history_break_id
      params.permit(:id)[:id]
    end

    def work_history_break_params
      params.require(:candidate_interface_work_history_break_form)
        .permit(
          :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)", :reason
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) }
          .transform_values(&:strip)
    end
  end
end
