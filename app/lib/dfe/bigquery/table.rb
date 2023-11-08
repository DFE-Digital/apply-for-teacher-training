require 'google/cloud/bigquery'

module DfE
  module Bigquery
    class Table
      def self.client
        @client ||= begin
          raise(ConfigurationError, "DfE::Bigquery: missing required config values: #{::DfE::Bigquery.missing_config}") unless ::DfE::Bigquery.valid_config?

          config = ::DfE::Bigquery.config

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
end
