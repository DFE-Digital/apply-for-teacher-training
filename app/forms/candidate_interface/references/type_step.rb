module CandidateInterface
  module References
    class TypeStep < DfE::WizardStep
      include Rails.application.routes.url_helpers

      attr_accessor :referee_type, :return_to_path
      validates :referee_type, presence: true

      delegate :reference_process, :return_to_path, :reference,
        :application_choice, to: :wizard

      def self.permitted_params
        [:referee_type]
      end

      def previous_step
        :first_step
      end

      def next_step
        # candidate_interface
        # references
        # reference_name
        #
        # if the routes is not defined like these will raise an error
        #return_to_path || :reference_name

        return_to_path || process_next_path
      end

      private

      def process_next_path
        #### Same path, can we clean this up?
        case reference_process
        when 'candidate-details'
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference&.id,
          )
        when 'accept-offer'
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference&.id,
            params: {
              application_id: application_choice&.id
            },
          )
        when 'request-reference'
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference&.id,
          )
        end
      end

      #def next_step_path_arguments
      #  { referee_type: referee_type, id: reference&.id }
      #end
    end
  end
end
