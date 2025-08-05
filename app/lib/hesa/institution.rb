module Hesa
  class Institution
    include ActiveModel::Model

    attr_accessor :id, :name, :hesa_code, :suggestion_synonyms, :match_synonyms, :dttp_id, :ukprn, :comment, :closed, :has_never_awarded_degrees, :institution_groups, :postcode
    alias hesa_itt_code= hesa_code=

    class << self
      def all
        DfE::ReferenceData::Degrees::INSTITUTIONS.all.map { |institution_data| new(institution_data.to_h) }
      end

      def names
        all.map(&:name)
      end

      def find_by_name(name)
        result = DfE::ReferenceData::Degrees::INSTITUTIONS.all
          .find { |institution| institution.name == name || name.in?(institution.match_synonyms || []) }

        new(result.to_h) if result.present?
      end
    end
  end
end
