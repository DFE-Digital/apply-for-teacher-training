module DfE
  class WizardStep
    include ActiveModel::Model

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

    def next_step
      raise NotImplementedError
    end
  end
end
