module CandidateInterface
  class ReferenceWizard < DfE::Wizard::Base
    attr_accessor :reference_process, :current_application, :application_choice,
                  :reference, :return_to_path

    steps do
      [
        { reference_type: References::TypeStep },
        { reference_name: References::NameStep },
        { reference_email_address: References::EmailAddressStep },
        { reference_relationship: References::RelationshipStep },
      ]
    end

    store ReferenceStore
  end
end
