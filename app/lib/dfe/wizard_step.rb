module DfE
  class WizardStep
    include ActiveModel::Model

    def next_step
      raise NotImplementedError
    end
  end
end
