module DfE
  module Bigquery
    module Relation
      def table
        ::DfE::Bigquery::Table.new(name: table_name)
      end

      delegate :where, :order, to: :table

      def self.table_name
        raise NotImplementedError
      end
    end
  end
end
