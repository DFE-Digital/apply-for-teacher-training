module DfE
  module Bigquery
    module Relation
      def table
        ::DfE::Bigquery::Table.new(name: table_name)
      end

      delegate :select, :where, :order, to: :table

      def query(sql_query)
        ::DfE::Bigquery.client.query(sql_query, dataset:).map { |result| result_class.new(result) }
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
