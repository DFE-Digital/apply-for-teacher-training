module DfE
  class Wizard
    attr_reader :current_step_name
    attr_writer :step_params

    delegate :next_step, to: :current_step

    def initialize(current_step:, step_params: {})
      @current_step_name = current_step
      @step_params = step_params
    end

    def self.steps
      return @steps unless block_given?

      @steps = yield
    end

    def current_step
      instance_current_step if step_form_object_class.present?
    end

    def valid_step?
      current_step.valid?
    end

    def invalid_step?
      !valid_step?
    end

    def step_params
      if @step_params.respond_to?(:permit)
        @step_params.permit(permitted_params)
      else
        @step_params
      end
    end

    def instance_current_step
      @instance_current_step ||= step_form_object_class.new(step_params[current_step_name])
    end

    def step_form_object_class
      Array(self.class.steps).find { |step_config| step_config[current_step_name] }&.fetch(current_step_name)
    end

    delegate :permitted_params, to: :step_form_object_class
  end
end
