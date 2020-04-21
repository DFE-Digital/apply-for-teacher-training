module CandidateInterface
  class SafeguardingController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :redirect_to_application_form_unless_feature_flag_active

    def show; end

    def edit
      @safeguarding = SafeguardingIssuesDeclarationForm.build_from_application(current_application)
    end

    def update
      @safeguarding = SafeguardingIssuesDeclarationForm.new(safeguarding_params)

      if @safeguarding.save(current_application)
        redirect_to candidate_interface_review_safeguarding_path
      else
        render :edit
      end
    end

  private

    def safeguarding_params
      params.require(:candidate_interface_safeguarding_issues_declaration_form)
        .permit(:share_safeguarding_issues, :safeguarding_issues)
    end

    def redirect_to_application_form_unless_feature_flag_active
      redirect_to candidate_interface_application_form_path unless FeatureFlag.active?('suitability_to_work_with_children')
    end
  end
end
