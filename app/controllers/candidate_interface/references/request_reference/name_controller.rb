module CandidateInterface
  module References
    class RequestReference::NameController < NameController
#      include RequestReferenceOfferDashboard

#      def next_path
#        candidate_interface_request_reference_references_email_address_path(
#          @reference&.id || current_application.application_references.creation_order.last.id,
#        )
#      end
#
#      private
#
#      def set_wizard
#        @wizard = ReferenceWizard.new(
#          current_step: :reference_name,
#          reference_process: :request_reference,
#          current_application:,
#          reference: @reference,
#          return_to_path:,
#          step_params: ActionController::Parameters.new(
#            {
#              reference_name: {
#                name: params.dig(:name, :name),
#                referee_type: params[:referee_type] || @reference&.referee_type,
#              }
#            }
#          )
#        )
#      end
    end
  end
end
