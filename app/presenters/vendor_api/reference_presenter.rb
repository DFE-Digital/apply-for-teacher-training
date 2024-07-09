module VendorAPI
  class ReferencePresenter < Base
    attr_reader :reference

    def initialize(version, reference, application_accepted: false)
      super(version)
      @reference = reference
      @application_accepted = application_accepted
    end

    def as_json
      schema.to_json
    end

    def schema
      {
        id: reference.id,
        name: reference.name,
        email: reference.email_address,
        relationship: reference.relationship,
        reference: (reference.feedback if reference_received?),
        referee_type: reference.referee_type,
        safeguarding_concerns: (reference.has_safeguarding_concerns_to_declare? if reference_received?),
      }.tap do |hash|
        hash[:reference_received] = reference_received? if version_1_3_or_above?
      end
    end

  private

    attr_reader :application_accepted
    alias application_accepted? application_accepted

    def reference_received?
      reference.feedback_provided? && application_accepted?
    end
  end
end
