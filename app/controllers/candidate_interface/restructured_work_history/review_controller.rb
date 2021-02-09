module CandidateInterface
  class RestructuredWorkHistory::ReviewController < RestructuredWorkHistory::BaseController
    def show
      @application_form = current_application
    end

    def complete
      @application_form = current_application

      if section_marked_as_complete? && unexplained_gaps?
        flash[:warning] = 'You cannot mark this section complete with unexplained work breaks.'

        render :show
      else
        current_application.update!(application_form_params)

        redirect_to candidate_interface_application_form_path
      end
    end

  private

    def unexplained_gaps?
      breaks = WorkHistoryWithBreaks.new(current_application).timeline
      breaks.any? { |entry| entry.is_a?(WorkHistoryWithBreaks::BreakPlaceholder) }
    end

    def application_form_params
      strip_whitespace params.require(:application_form).permit(:work_history_completed)
    end

    def section_marked_as_complete?
      application_form_params[:work_history_completed] == 'true'
    end
  end
end
