module DfE
  class WizardStep
    include ActiveModel::Model

    def permitted_params
      raise NotImplementedError
    end

    def next_step
      raise NotImplementedError
    end
  end
end
