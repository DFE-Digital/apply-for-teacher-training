module Hesa
  class Institution
    include ActiveModel::Model
    attr_accessor :id, :name, :hesa_code, :suggestion_synonyms, :match_synonyms, :dttp_id, :ukprn, :comment, :closed, :has_never_awarded_degrees
    alias hesa_itt_code= hesa_code=

    class << self
      def all
        DfE::ReferenceData::Degrees::INSTITUTIONS.all.map { |institution_data| new(institution_data.to_h) }
      end

      def names
        all.map(&:name)
      end

      def find_by_name(name)
        all.find { |institution| institution.name == name || name.in?(institution.match_synonyms) }
      end
    end
  end
end
