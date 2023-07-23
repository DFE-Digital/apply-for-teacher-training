module DfE
  class Wizard
    attr_reader :current_step_name, :steps, :request
    attr_writer :step_params

    delegate :next_step, to: :current_step
    delegate :info, to: :logger, allow_nil: true

    def initialize(current_step:, request:, step_params: {}, **args)
      @current_step_name = current_step
      @step_params = step_params
      @request = request
      @steps = self.class.steps

      (args || {}).each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
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

    def current_step
      instance_current_step if step_form_object_class.present?
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

    def store
      @store ||= self.class.store.new(self) if self.class.store.present?
    end

    def step_params
      if @step_params.respond_to?(:permit) && @step_params.key?(current_step_name)
        @step_params.require(current_step_name).permit(permitted_params)
      else
        @step_params[current_step_name]
      end
    end

    def instance_current_step
      info("Instantiate steps with: #{current_step_params}") if @instance_current_step.blank?

      @instance_current_step ||= step_form_object_class.new(current_step_params.merge(url_helpers:))
    end

    def step_form_object_class
      find_step(current_step_name)
    end

    def previous_step_path(back: false, fallback: nil)
      return referer_path(fallback) if back.present?

      previous_step_name = current_step.previous_step

      return referer_path(fallback) if previous_step_name == :first_step
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
      next_step_klass = find_step(next_step_name)

      if next_step_klass.present?
        info("Next step name defined: #{next_step_name}")
        info("Next step class found: #{next_step_klass}")
        current_step.next_step_path(next_step_klass)
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

    def referer_path(fallback)
      return fallback if referer.blank? || (referer_host.present? && referer_host != request.host)

      referer
    end

    def referer_host
      URI(referer).host
    end

    def referer
      request.env['HTTP_REFERER']
    end

    delegate :permitted_params, to: :step_form_object_class

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
