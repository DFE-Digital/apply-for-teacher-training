module DfE
  module Bigquery
    class ConfigurationError < StandardError; end

    def self.config
      configurables = %i[
        bigquery_retries
        bigquery_timeout
        bigquery_api_json_key
        bigquery_project_id
      ]

      @config ||= Struct.new(*configurables).new
    end

    def self.configure
      yield(config)
    end
  end
end
