module DfE
  class WizardStore
    attr_accessor :wizard
    delegate :current_step, :current_step_name, to: :wizard

    def initialize(wizard)
      @wizard = wizard
    end

    def save
      raise NotImplementedError
    end
  end
end
