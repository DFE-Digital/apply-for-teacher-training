module DfE
  class WizardStore
    attr_accessor :wizard
    delegate :current_step, :current_step_name, to: :wizard
    delegate :name, to: :current_step

    def initialize(wizard)
      @wizard = wizard
    end

    def save
      raise NotImplementedError
    end
  end
end
