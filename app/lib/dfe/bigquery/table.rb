module DfE
  module Bigquery
    class Table
      attr_accessor :name, :conditions, :order_clause

      def initialize(name:)
        @name = name
        @conditions = []
      end

      def where(conditions)
        @conditions << Array(conditions).map { |column, value| Condition.new(column:, value:) }
        @conditions.flatten!

        self
      end

      def order(options)
        @order_clause = options

        self
      end

      def to_sql
        base_sql = "SELECT *\nFROM #{name}\n"

        if @conditions.present?
          @conditions.each_with_index do |condition, index|
            base_sql << (index.zero? ? 'WHERE ' : 'AND ')

            base_sql << condition.to_sql
          end
        end

        if @order_clause.present?
          base_sql << "ORDER BY #{@order_clause.keys.first} #{@order_clause.values.first.to_s.upcase}\n"
        end

        base_sql
      end
    end
  end
end
