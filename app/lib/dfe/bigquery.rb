require 'google/cloud/bigquery'

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

    # @return [Google::Cloud::Bigquery::Project]
    def self.client
      @client ||= begin
        raise(ConfigurationError, "DfE::Bigquery: missing required config values: #{missing_config}") unless valid_config?

        Google::Cloud::Bigquery.new(
          project: config.bigquery_project_id,
          credentials: JSON.parse(config.bigquery_api_json_key),
          retries: config.bigquery_retries,
          timeout: config.bigquery_timeout,
        )
      end
    end
  end
end
