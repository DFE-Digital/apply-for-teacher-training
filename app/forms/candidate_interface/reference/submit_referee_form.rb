module CandidateInterface
  class Reference::SubmitRefereeForm
    include ActiveModel::Model

    attr_accessor :submit, :reference_id

    validates :submit, presence: true
    validate :all_details_provided?

    def send_request?
      submit == 'yes'
    end

  private

    def all_details_provided?
      reference = ApplicationReference.find(reference_id)

      return true if CandidateInterface::Reference::TypeStep.new(referee_type: reference.referee_type).valid? &&
                     CandidateInterface::Reference::NameStep.new(name: reference.name, referee_type: reference.referee_type).valid? &&
                     email_step(reference).valid? &&
                     CandidateInterface::Reference::RelationshipStep.new(relationship: reference.relationship).valid?

      errors.add(:submit, :incomplete)
    end

    def email_step(reference)
      ReferenceWizard.new(
        current_step: :reference_email_address,
        reference: reference,
        step_params: ActionController::Parameters.new(
          {
            reference_email_address: {
              email_address: reference.email_address,
            },
          },
        ),
      ).current_step
    end
  end
end
