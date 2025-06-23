module ProviderInterface
  class ReferencesController < ProviderInterfaceController
    before_action :set_application_choice, :redirect_if_unsuccessful, :set_references, :set_workflow_flags, :redirect_if_application_changed_provider

    after_action :track_if_pdf_download, only: %i[index]

    def index; end

  private

    def redirect_if_unsuccessful
      redirect_to provider_interface_application_choice_path(@application_choice) if @application_choice.application_unsuccessful_without_inactive?
    end

    def set_references
      @references = @application_choice.application_form.application_references
                                       .where(feedback_status: %i[not_requested_yet feedback_requested feedback_provided])

      @references = @references.selected unless new_references_flow?
    end

    def new_references_flow?
      @application_choice.application_form.recruitment_cycle_year > ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR
    end
  end
end
