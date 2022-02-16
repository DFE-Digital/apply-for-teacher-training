module DfE
  module ReferenceData
    ##
    #
    # A +JoinedReferenceList+ is a wrapper around one or more +ReferenceList+s with
    # disjoint (non-overlapping) ID ranges, which joins them all together into one
    # big one.
    class JoinedReferenceList < ReferenceList
      def initialize(lists)
        super()
        @lists = lists
      end

      def all
        all = []
        @lists.each_entry do |list|
          all += list.all
        end
        all
      end

      def all_as_hash
        all = {}
        @lists.each_entry do |list|
          all.merge(list.all_as_hash)
        end
        all
      end

      def one(id)
        final_result = nil
        @lists.find do |list|
          result = list.one(id)
          if result.nil?
            false
          else
            final_result = result
            true
          end
        end
        final_result
      end
    end
  end
end
