module DfE
  class Wizard
    attr_reader :current_step_name, :steps
    attr_writer :step_params
    attr_accessor :edit

    delegate :next_step, to: :current_step
    delegate :info, to: :logger, allow_nil: true

    def initialize(current_step:, step_params: {}, **args)
      @current_step_name = current_step
      @step_params = step_params
      @steps = self.class.steps

      (args || {}).each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    def self.steps
      return @steps unless block_given?

      @steps = yield
    end

    def self.store(store_service = nil)
      @store ||= store_service
    end

    def logger; end

    def edit?
      @edit.present?
    end

    def current_step
      current_step_instance if step_object_class.present?
    end

    def valid_step?
      current_step.valid?
    end

    def invalid_step?
      !valid_step?
    end

    def save
      store.save if store.present?
    end

    def update
      store.update if store.present?
    end

    def store
      @store ||= self.class.store.new(self) if self.class.store.present?
    end

    def step_params
      @step_params.require(current_step_name).permit(permitted_params) if @step_params && @step_params[current_step_name].present?
    end

    def current_step_instance
      info("Instantiate steps with: #{current_step_params}") if @current_step_instance.blank?

      @current_step_instance ||= step_object_class.new(current_step_params.merge(wizard: self))
    end

    def step_object_class
      find_step(current_step_name)
    end

    def previous_step_path(fallback: nil)
      previous_step_name = current_step.previous_step
      return fallback if previous_step_name == :first_step

      previous_step_klass = find_step(previous_step_name)

      if previous_step_klass.present?
        info("Previous step name defined: #{previous_step_name}")
        info("Previous step class found: #{previous_step_klass}")
        current_step.previous_step_path(previous_step_klass)
      else
        info('Previous step class not found')
        raise MissingStepError, "Previous step for #{current_step.step_name} missing."
      end
    end

    def next_step_path
      info("Finding next step for #{current_step.step_name}")
      next_step_name = current_step.next_step

      return current_step.exit_path if next_step_name == :exit

      next_step_klass = find_step(next_step_name)

      if next_step_klass.present?
        info("Next step name defined: #{next_step_name}")
        info("Next step class found: #{next_step_klass}")
        if edit?
          current_step.next_edit_step_path(next_step_klass)
        else
          current_step.next_step_path(next_step_klass)
        end
      else
        info('Next step class not found')
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

    delegate :permitted_params, to: :step_object_class

    class MissingStepError < StandardError
    end

    class Logger
      attr_reader :logger, :options

      def initialize(logger, options = {})
        @logger = logger
        @options = options
      end

      def info(message)
        return if options[:if].is_a?(Proc) && options[:if].call.blank?

        @logger.info(
          "#{ActiveSupport::LogSubscriber.new.send(:color, 'DfE::Wizard', :yellow)} #{message}",
        )
      end
    end
  end
end
