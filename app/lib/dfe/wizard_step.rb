module DfE
  class WizardStep
    include ActiveModel::Model
    attr_accessor :wizard
    delegate :store, :url_helpers, to: :wizard

    def self.model_name
      ActiveModel::Name.new(self, nil, formatted_name.demodulize)
    end

    def self.formatted_name
      name.gsub('Step', '')
    end

    def self.route_name
      formatted_name.underscore.gsub('/', '_')
    end

    def self.permitted_params
      raise NotImplementedError
    end

    def step_name
      self.class.model_name.name
    end

    def previous_step
      raise NotImplementedError
    end

    def next_step
      raise NotImplementedError
    end

    def next_edit_step_path(next_step_klass)
      url_helpers.public_send("edit_#{next_step_klass.route_name}_path", next_step_path_arguments)
    end

    def next_step_path(next_step_klass)
      url_helpers.public_send("#{next_step_klass.route_name}_path", next_step_path_arguments)
    end

    def previous_step_path(previous_step_klass)
      url_helpers.public_send("#{previous_step_klass.route_name}_path", previous_step_path_arguments)
    end

    def next_step_path_arguments; end

    def previous_step_path_arguments; end
  end
end
