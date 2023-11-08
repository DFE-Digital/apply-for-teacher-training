module DfE
  module Bigquery
    class ConfigurationError < StandardError; end
    CONFIGURABLES = %i[
      bigquery_retries
      bigquery_timeout
      bigquery_api_json_key
      bigquery_project_id
    ].freeze

    def self.config
      @config ||= Struct.new(*CONFIGURABLES).new
    end

    def self.configure
      yield(config)
    end

    def self.valid_config?
      missing_config.none?
    end

    def self.missing_config
      CONFIGURABLES.select { |value| config.send(value).nil? }
    end
  end
end
