module CandidateInterface
  module DecoupledReferences
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_application_form_if_flag_is_not_active

      def start; end

      def name
        @reference_name_form = Reference::RefereeNameForm.new
      end

      def update_name
        @reference_name_form = Reference::RefereeNameForm.new(name: referee_name_param)
        return render :name unless @reference_name_form.valid?

        @reference_name_form.save(@reference)

        redirect_to candidate_interface_decoupled_references_email_path(@reference.id)
      end

    private

      def redirect_to_application_form_if_flag_is_not_active
        redirect_to candidate_interface_application_form_path unless FeatureFlag.active?('decoupled_references')
      end

      def referee_name_param
        params.dig(:candidate_interface_reference_referee_name_form, :name)
      end
    end
  end
end
