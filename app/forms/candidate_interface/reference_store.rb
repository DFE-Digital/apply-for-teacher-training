module CandidateInterface
  class ReferenceStore < DfE::WizardStore
    delegate :current_application, :reference, :current_step_params, to: :wizard

    def save
      return false unless wizard.valid_step?

      if reference
        reference.update!(current_step_params)
      else
        current_application.application_references.create!(current_step_params)
      end

      true
    end

    def update
    #  return false unless wizard.valid_step?

    #  @application_choice = if wizard.completed?
    #                          save_application_choice(
    #                            wizard.application_choice,
    #                          )
    #                        else
    #                          wizard.application_choice
    #                        end
    end

    private
  end
end
