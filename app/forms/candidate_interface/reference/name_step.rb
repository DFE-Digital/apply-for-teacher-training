module CandidateInterface
  module Reference
    class NameStep < DfE::Wizard::Step
      include Rails.application.routes.url_helpers

      attr_accessor :name, :referee_type
      delegate :reference_process, :current_application, :reference,
               :application_choice, :return_to_path, to: :wizard

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }

      def self.permitted_params
        %i[name referee_type]
      end

      def previous_step
        return_to_path || candidate_interface_references_type_path(
          reference_process,
          referee_type,
          reference&.id,
          application_id: application_choice&.id,
        )
      end

      def next_step
        return_to_path || process_next_path
      end

    private

      def process_next_path
        if reference_process == 'accept-offer'
          candidate_interface_references_email_address_path(
            reference_process,
            reference&.id ||
              current_application.application_references.creation_order.last.id,
            application_id: application_choice&.id,
          )
        else
          candidate_interface_references_email_address_path(
            reference_process,
            reference&.id || current_application.application_references.creation_order.last.id,
          )
        end
      end
    end
  end
end
