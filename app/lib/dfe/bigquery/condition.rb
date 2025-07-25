module DfE
  module Bigquery
    class Condition
      include ActiveModel::Model

      attr_writer :value
      attr_accessor :column

      def value
        if @value.is_a? Numeric
          @value
        else
          "\"#{@value}\""
        end
      end

      def to_sql
        return "#{column} = #{value}\n" if @value.present?

        "#{column}\n"
      end
    end
  end
end
