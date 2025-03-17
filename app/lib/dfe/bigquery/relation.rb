module DfE
  module Bigquery
    module Relation
      JobIncompleteError = Class.new(StandardError)
      MorePagesError = Class.new(StandardError)
      UnknownTypeError = Class.new(StandardError)

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

        # If there are no results we should return early
        # BigqueryV2 client sets rows to nil if there are no results
        return [] if result.rows.blank?

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

            value = parse_value(raw_value, field.type)
            memo[field_name] = value
          end.symbolize_keys
        end

        processed_results.map { |row| result_class.new(row) }
      end

      def table_name
        raise NotImplementedError
      end

      # https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types
      def parse_value(raw_value, type)
        return nil if raw_value.nil?

        case type
        when 'STRING'
          raw_value
        when 'INTEGER'
          Integer(raw_value)
        when 'DATE'
          Date.parse(raw_value)
        when 'DATETIME', 'TIME'
          Time.zone.parse(raw_value)
        when 'BOOLEAN'
          ActiveModel::Type::Boolean.new.cast(raw_value)
        when 'FLOAT'
          Float(raw_value)
        when 'RECORD'
          nil
        else
          raise UnknownTypeError, "cannot parse this type of value: '#{type}'"
        end
      end
    end
  end
end
