module DfE
  module ReferenceData
    class Record < OpenStruct
      attr_reader :data
      delegate :[], :[]=, :merge, :key?, :values, :keys, to: :data

      def initialize(data)
        @data = data

        super
      end

      def ==(other)
        data == if other.is_a?(Hash)
                  other
                else
                  other.data
                end
      end
    end
  end
end
