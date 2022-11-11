module CandidateInterface
  module References
    class RequestReference::EmailAddressController < EmailAddressController
      include RequestReferenceOfferDashboard

      def next_path
        candidate_interface_request_reference_references_relationship_path(
          @reference.id,
        )
      end

      def set_email_address_form
        @reference_email_address_form = Reference::RequestRefereeEmailAddressForm.new(referee_email_address_param)
      end
    end
  end
end
