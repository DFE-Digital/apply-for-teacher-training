module CandidateInterface
  class ReferenceStore < DfE::Wizard::Store
    delegate :current_application, :reference, :current_step_params, to: :wizard

    def save
      return false unless wizard.valid_step?

      ApplicationForm.with_unsafe_application_choice_touches do
        if reference
          reference.update!(current_step_params)
        else
          current_application.application_references.create!(current_step_params)
        end
      end
      true
    end
  end
end
