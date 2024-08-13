module DfE
  module Bigquery
    module Relation
      JobIncompleteError = Class.new(StandardError)
      MorePagesError = Class.new(StandardError)

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

        result = ::DfE::Bigquery.client.query_job(
          DfE::Bigquery.config.bigquery_project_id,
          query_object,
        )

        unless result.job_complete?
          raise JobIncompleteError, 'the query job did not complete for some reason'
        end

        if result.page_token
          raise MorePagesError, 'the query returned more results than can fit in one page'
        end

        processed_results = result.rows.map do |row|
          result.schema.fields.each_with_object({}).with_index do |(field, memo), index|
            field_name = field.name
            raw_value = row.f[index].v

            memo[field_name] = raw_value
          end.symbolize_keys
        end

        processed_results.map { |row| result_class.new(row) }
      end

      def table_name
        raise NotImplementedError
      end
    end
  end
end
