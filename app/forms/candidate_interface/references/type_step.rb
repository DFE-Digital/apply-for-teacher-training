module CandidateInterface
  module References
    class TypeStep < DfE::Wizard::Step
      include Rails.application.routes.url_helpers

      attr_accessor :referee_type, :return_to_path
      validates :referee_type, presence: true

      delegate :reference_process, :return_to_path, :reference,
               :application_choice, to: :wizard

      def self.permitted_params
        [:referee_type]
      end

      def previous_step
        return return_to_path if return_to_path.present?

        if reference_process == 'candidate_details'
          candidate_interface_references_start_path(reference_process)
        elsif reference_process == 'request-reference'
          candidate_interface_start_new_reference_path(reference_process)
        elsif reference_process == 'accept-offer'
          candidate_interface_accept_offer_path(application_choice)
        end
      end

      def next_step
        # candidate_interface
        # references
        # reference_name
        #
        # if the routes is not defined like these will raise an error

        return_to_path || process_next_path
      end

    private

      def process_next_path
        if reference_process == 'accept-offer'
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference&.id,
            application_id: application_choice&.id,
          )
        else
          candidate_interface_references_name_path(
            reference_process,
            referee_type,
            reference&.id,
          )
        end
      end

      # def next_step_path_arguments
      #  { referee_type: referee_type, id: reference&.id }
      # end
    end
  end
end
