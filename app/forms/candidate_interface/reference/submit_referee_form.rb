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

      return true if Reference::RefereeTypeForm.build_from_reference(reference).valid? &&
                     Reference::RefereeNameForm.build_from_reference(reference).valid? &&
                     Reference::RefereeRelationshipForm.build_from_reference(reference).valid? &&
                     Reference::RefereeEmailAddressForm.build_from_reference(reference).valid?

      errors.add(:submit, :incomplete)
    end
  end
end
