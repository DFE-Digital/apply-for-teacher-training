module DfE
  module Bigquery
    class Table
      def self.client
        require 'google/cloud/bigquery'

        config = ::DfE::Bigquery.config

        missing_config = %i[
          bigquery_project_id
          bigquery_api_json_key
          bigquery_retries
          bigquery_timeout
        ].select { |val| config.send(val).nil? }

        raise(ConfigurationError, "DfE::Bigquery: missing required config values: #{missing_config.join(', ')}") if missing_config.any?

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
