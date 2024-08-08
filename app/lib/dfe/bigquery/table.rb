module DfE
  module Bigquery
    class Table
      attr_accessor :name, :conditions, :order_clause

      def initialize(name:)
        @name = name
        @select = '*'
        @conditions = []
      end

      def select(columns)
        @select = if columns.is_a? Array
                    columns.join(', ')
                  elsif columns.is_a? String
                    columns
                  else
                    @select
                  end

        self
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
        base_sql = "SELECT #{@select}\nFROM `#{name}`\n"

        if @conditions.present?
          @conditions.each_with_index do |condition, index|
            base_sql << (index.zero? ? 'WHERE ' : 'AND ')

            base_sql << condition.to_sql
          end
        end

        if @order_clause.present?
          order_clause_key = @order_clause.keys.first
          base_sql << "#{default_order_clause(order_clause_key)}, #{order_clause_key} #{@order_clause.values.first.to_s.upcase}\n"
        end

        base_sql
      end

    private

      def default_order_clause(order_clause_key)
        <<~SQL
          ORDER BY (
            CASE WHEN #{order_clause_key}='Prefer not to say' THEN 4
                 WHEN #{order_clause_key}='Unknown' THEN 3
                 WHEN #{order_clause_key}='Other' OR #{order_clause_key}='Others' THEN 2
                 ELSE 1
            END
          )
        SQL
      end
    end
  end
end
