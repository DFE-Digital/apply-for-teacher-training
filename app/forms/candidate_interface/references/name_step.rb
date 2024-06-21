module CandidateInterface
  module References
    class NameStep < DfE::Wizard::Step
      include Rails.application.routes.url_helpers
      attr_accessor :name, :referee_type
      delegate :reference_process, :current_application, :reference,
        :application_choice, :return_to_path, to: :wizard

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }

      def self.permitted_params
        [:name, :referee_type]
      end

      def previous_step
        :reference_type
      end

      def next_step
        # candidate_interface
        # references
        # reference_name
        #
        # if the routes is not defined like these will raise an error
        #
        #  candidate_interface_references_reference_name_path()
        #
        #:reference_email_address

        return_to_path || process_next_path
      end

      #def next_step_path_arguments
      #  reference&.id ||
      #    current_application.application_references.creation_order.last.id
      #end

      private

      def process_next_path
        case reference_process
        when 'candidate-details'
          candidate_interface_references_email_address_path(
            reference_process,
            reference&.id || current_application.application_references.creation_order.last.id
          )
        when 'accept-offer'
          candidate_interface_references_email_address_path(
            reference_process,
            reference&.id ||
              current_application.application_references.creation_order.last.id,
            params: { application_id: application_choice&.id },
          )
        when 'request-reference'
          candidate_interface_references_email_address_path(
            reference_process,
            reference&.id || current_application.application_references.creation_order.last.id
          )
        end
      end
    end
  end
end
