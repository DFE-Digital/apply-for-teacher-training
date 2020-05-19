module CandidateInterface
  class SafeguardingController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
    end

    def edit
      @safeguarding = SafeguardingIssuesDeclarationForm.build_from_application(current_application)
    end

    def update
      @safeguarding = SafeguardingIssuesDeclarationForm.new(safeguarding_params)

      if @safeguarding.save(current_application)
        current_application.update!(safeguarding_issues_completed: false)

        redirect_to candidate_interface_review_safeguarding_path
      else
        render :edit
      end
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def safeguarding_params
      params.require(:candidate_interface_safeguarding_issues_declaration_form)
        .permit(:share_safeguarding_issues, :safeguarding_issues)
    end

    def application_form_params
      params.require(:application_form).permit(:safeguarding_issues_completed)
        .transform_values(&:strip)
    end
  end
end
