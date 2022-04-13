module CandidateAPI
  module Serializers
    class Base
      attr_reader :updated_since

      def initialize(updated_since:)
        @updated_since = updated_since
      end
    end
  end
end
