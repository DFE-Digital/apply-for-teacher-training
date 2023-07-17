module DfE
  class Wizard
    attr_reader :current_step_name, :step_params

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
      form_object_class = Array(self.class.steps).find { |step_config| step_config[current_step_name] }&.fetch(current_step_name)

      form_object_class.new(step_params[current_step_name]) if form_object_class.present?
    end
  end
end
