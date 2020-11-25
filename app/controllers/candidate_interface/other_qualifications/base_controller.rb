module CandidateInterface
  class OtherQualifications::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :render_application_feedback_component

    def current_qualification
      @current_qualification ||= current_application.application_qualifications.other.find(params[:id])
    end

  private

    def reset_intermediate_state!
      intermediate_data_service.clear_state!
    end

    def intermediate_data_service
      @intermediate_data_service ||= IntermediateDataService.new(
        WizardStateStores::RedisStore.new(
          key: persistence_key_for_current_user,
        ),
      )
    end

    def persistence_key_for_current_user
      "candidate_user_other_qualification_flow-#{current_candidate.id}"
    end
  end
end
