module DfE
  class Wizard
    attr_reader :current_step_name, :steps
    attr_writer :step_params

    delegate :next_step, to: :current_step

    def initialize(current_step:, step_params: {})
      @current_step_name = current_step
      @step_params = step_params
      @steps = self.class.steps
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
      if @step_params.respond_to?(:permit) && @step_params.key?(current_step_name)
        @step_params.require(current_step_name).permit(permitted_params)
      else
        @step_params[current_step_name]
      end
    end

    def instance_current_step
      @instance_current_step ||= step_form_object_class.new(current_step_params.merge(url_helpers:))
    end

    def step_form_object_class
      find_step(current_step_name)
    end

    def next_step_path
      next_step_klass = find_step(current_step.next_step)

      if next_step_klass.present?
        current_step.next_step_path(next_step_klass)
      else
        raise MissingStepError, "Next step for #{current_step.step_name} missing."
      end
    end

    def current_step_path(args = nil)
      url_helpers.public_send("#{current_step.class.route_name}_path", args)
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    def find_step(step_name)
      Array(steps).find { |step_config| step_config[step_name] }&.fetch(step_name)
    end

    def current_step_params
      step_params || {}
    end

    delegate :permitted_params, to: :step_form_object_class

    class MissingStepError < StandardError
    end
  end
end
