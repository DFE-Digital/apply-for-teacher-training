module DfE
  module ReferenceData
    ##
    #
    # A +TweakedReferenceList+ is a wrapper around a +ReferenceList+ that applies
    # some local "tweaks" - overrides to the underlying list that either add new
    # records, add new fields to existing records, overwrite existing fields in
    # existing records, or hide some records.
    class TweakedReferenceList < ReferenceList
      ##
      # +TweakedReferenceList+ constructor. +base+ must be a +ReferenceList+;
      # +overrides+ must be a hash mapping IDs to either hashes of fields or
      # +nil+. If mapped to +nil+, then the record with that ID is hidden from the
      # base list. Otherwise, the fields in the hash are merged into the
      # corresponding record from the base, or simply become the record if there is
      # no record with that ID in the base.
      #
      # The base list is not modified - this merely wraps it to create a new
      # reference list with some "tweaks" applied.+
      def initialize(base, overrides)
        super()
        @base = base
        @overrides = overrides

        @overridden_all = base.all_as_hash.clone

        overrides.each_entry do |id, record|
          if record.nil?
            @overridden_all.delete(id)
          elsif @overridden_all.key? id
            old_record = @overridden_all[id]
            @overridden_all[id] = old_record.merge(record)
          else
            @overridden_all[id] = record.merge({ id: id })
          end
        end
      end

      def all
        @overridden_all.values
      end

      def all_as_hash
        @overridden_all
      end

      def one(id)
        if @overrides.key?(id)
          override = @overrides[id]
          if override.nil? # Hidden record
            nil
          else
            old_record = @base.one(id)
            if old_record.nil? # Added record
              override.merge({ id: id })
            else # Modified record
              old_record.merge(override)
            end
          end
        else # Un-overridden record
          @base.one(id)
        end
      end
    end
  end
end
