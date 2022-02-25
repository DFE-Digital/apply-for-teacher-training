module DfE
  module ReferenceData
    ##
    #
    # A +ReferenceList+ is the core interface to a reference list (the clue's in the
    # name, right?); this class is abstract, defining various utility methods that
    # subclasses are likely to be able to re-use the implementations of.
    class ReferenceList
      # Abstract methods, override these please

      ##
      # Get all the records in the list, as an array of hashes. Each hash maps field
      # name symbols to whatever values that field has in that record; every record
      # must have a field called +id+ that is a unique primary key for that list -
      # eg, no other record has the same +id+.
      def all
        raise NotImplementedError
      end

      ##
      # Get all the records in the list, as a hash of hashes. The top-level hash
      # maps an ID to the record with that ID.
      def all_as_hash
        raise NotImplementedError
      end

      ##
      # Get a single record from the list, given the value of its +id+ field. The
      # record is returned as a hash mapping field name symbols to values. If there
      # is no record with that +id+, returns +nil+.
      def one(record_id)
        raise NotImplementedError
      end

      # Utility methods, don't override these unless you have better implementations

      ##
      # Get all the records in the list matching the specified +filter+.
      #
      # The +filter+ is a hash mapping field names to values; records that "match"
      # the filter have those values for those fields. However, if +filter+ is
      # +nil+, all records are returned.
      #
      # The records are returned as an array of hashes, one per record, mapping
      # field name symbols to whatever values that field has in that record.
      def some(filter)
        all_records = all
        if filter.nil?
          all_records
        else
          all_records.find_all do |x|
            filter.all? do |field, value|
              x[field] == value
            end
          end
        end
      end

      ##
      # Get all records in the list matching the specified +filter+, organised by +field+.
      #
      # See the #some method for details of how +filter+ works, including
      # specifying +nil+ to get all records.
      #
      # The result is returned as a hash mapping values of +field+ found in the
      # records to arrays of records with that specific value of +field+.
      #
      # Any records found that do not have a value for +field+ will be ignored.
      #
      # The returned records are represented as hashes mapping field names to
      # whatever values those fields have for that record.
      #
      # As a future extension, we could support passing in a list of fields to
      # create a multi-level hash grouping records by a combination of fields, eg
      # +some_by_field([:a,:b])+ produces a hash with each value of +a+ as keys, and
      # values containing hashes mapping each value of +b+ found in records with
      # that particular value for +a+, to actual records with those values for +a+
      # and +b+. Like an SQL GROUP BY with multiple column names.
      def some_by_field(field, filter = nil)
        records = some(filter)
        result = {}
        records.each_entry do |record|
          next unless record.key? field

          field_value = record[field]
          result[field_value] = [] unless result.key? field_value
          result[field_value].push(record)
        end

        result
      end
    end
  end
end
