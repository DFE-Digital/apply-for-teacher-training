module DfE
  module ReferenceData
    ##
    #
    # A +HardcodedReferenceList+ is an implementation of +ReferenceList+ that uses a
    # hardcoded hash as the data source.
    class HardcodedReferenceList < ReferenceList
      class Record
        attr_reader :data
        delegate :[], :[]=, :merge, :key?, :values, :keys, to: :data

        def initialize(data)
          @data = data
        end

        def ==(other)
          if other.is_a?(Hash)
            data == other
          else
            data == other.data
          end
        end

        def respond_to_missing?(method_name, *args)
          data.has_key?(method_name)
        end

        def method_missing(method_name, *args, &block)
          if data.has_key?(method_name)
            data[method_name]
          else
            super
          end
        end
      end

      ##
      # +HardcodedReferenceList+ constructor. +data+ is a hash from IDs to records;
      # the records do not need to contain an +id+ field as those are provided
      # automatically.
      def initialize(data)
        super()
        @data = {}
#        @record_type = Struct.new(*data.values.map(&:keys).push(:id).flatten.uniq.map(&:to_sym), keyword_init: true)

        data.each_entry do |id, record|
          @data[id] = Record.new(record.merge({ id: id }))
        end
    #DuplicatedMatch = Struct.new(
    #  :email_address, :candidate_id, :created_at, :name, :date_of_birth, :address, :application_status, :account_status,
    #  keyword_init: true
    #)
      end

      def all
        @data.values
      end

      def all_as_hash
        @data
      end

      def one(id)
        @data[id]
      end
    end
  end
end
