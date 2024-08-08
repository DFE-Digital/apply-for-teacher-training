module DfE
  module Bigquery
    module Relation
      def table
        ::DfE::Bigquery::Table.new(name: table_name)
      end

      delegate :select, :where, :order, to: :table

      def query(sql_query)
        query_object = Google::Apis::BigqueryV2::QueryRequest.new(
          query: sql_query,
          timeout_ms: DfE::Bigquery.config.bigquery_timeout,
          use_legacy_sql: false,
        )

        ::DfE::Bigquery.client.query_job(
          DfE::Bigquery.config.bigquery_project_id,
          query_object,
        ).map { |result| result_class.new(result) }
      end

      def table_name
        raise NotImplementedError
      end

      def dataset
        raise NotImplementedError
      end
    end
  end
end
