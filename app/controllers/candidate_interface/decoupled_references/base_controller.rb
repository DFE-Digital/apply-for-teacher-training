module CandidateInterface
  module DecoupledReferences
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_application_form_if_flag_is_not_active

      def start; end

    private

      def redirect_to_application_form_if_flag_is_not_active
        redirect_to candidate_interface_application_form_path unless FeatureFlag.active?('decoupled_references')
      end

      def referee_name_param
        params.dig(:candidate_interface_reference_referee_name_form, :name)
      end

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end
    end
  end
end
