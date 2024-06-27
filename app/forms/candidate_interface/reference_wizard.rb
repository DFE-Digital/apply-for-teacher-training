module CandidateInterface
  class ReferenceWizard < DfE::Wizard::Base
    attr_accessor :reference_process, :current_application, :application_choice,
                  :reference, :return_to_path

    steps do
      [
        { reference_type: Reference::TypeStep },
        { reference_name: Reference::NameStep },
        { reference_email_address: Reference::EmailAddressStep },
        { reference_relationship: Reference::RelationshipStep },
      ]
    end

    store ReferenceStore
  end
end
