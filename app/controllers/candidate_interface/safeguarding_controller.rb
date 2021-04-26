module CandidateInterface
  class SafeguardingController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.safeguarding_issues_completed)
    end

    def edit
      @safeguarding_form = SafeguardingIssuesDeclarationForm.build_from_application(current_application)
    end

    def update
      @safeguarding_form = SafeguardingIssuesDeclarationForm.new(safeguarding_params)

      if @safeguarding_form.save(current_application)
        current_application.update!(safeguarding_issues_completed: false)

        redirect_to candidate_interface_review_safeguarding_path
      else
        track_validation_error(@safeguarding_form)
        render :edit
      end
    end

    def complete
      @section_complete_form = SectionCompleteForm.new(form_params)

      if @section_complete_form.save(current_application, :safeguarding_issues_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def safeguarding_params
      strip_whitespace params
        .require(:candidate_interface_safeguarding_issues_declaration_form)
        .permit(:share_safeguarding_issues, :safeguarding_issues)
    end

    def form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end
