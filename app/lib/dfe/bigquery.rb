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

    # @return [Google::Apis::BigqueryV2::BigqueryService]
    def self.client
      raise(ConfigurationError, "DfE::Bigquery: missing required config values: #{missing_config}") unless valid_config?

      Google::Apis::BigqueryV2::BigqueryService.new.tap do |service|
        service.request_options = Google::Apis::RequestOptions.default.dup.merge(
          retries: config.bigquery_retries,
          authorization: Azure::UserCredentials.call,
        )
      end
    end
  end
end
