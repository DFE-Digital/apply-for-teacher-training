module CandidateInterface
  class OtherQualifications::BaseController < SectionController
    before_action :render_application_feedback_component

    def current_qualification
      if instance_variable_defined?(:@current_qualification)
        @current_qualification
      else
        @current_qualification = current_application.application_qualifications.other.find_by(id: params[:id])
      end
    end

  private

    def intermediate_data_service
      @intermediate_data_service ||= IntermediateDataService.new(
        WizardStateStores::RedisStore.new(
          key: "candidate_user_other_qualification_flow-#{current_candidate.id}-#{params[:id] || 'new'}",
        ),
      )
    end
  end
end
