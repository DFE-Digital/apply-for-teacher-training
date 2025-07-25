module Hesa
  class DegreeType
    include ActiveModel::Model

    attr_accessor :id, :priority, :qualification, :topic, :suggestion_synonyms,
                  :match_synonyms, :dttp_id, :dqt_id, :hesa_code, :abbreviation, :name,
                  :deprecated, :comment, :hint, :generic
    alias hesa_itt_code= hesa_code=

    def shortest_display_name
      abbreviation || name
    end

    def master?
      level == :master
    end

    def bachelor?
      level == :bachelor
    end

    def doctor?
      level == :doctor
    end

    def foundation?
      level == :foundation
    end

    def level
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.one(qualification)&.degree
    end

    UNDERGRADUATE_LEVELS = %i[bachelor master].freeze

    class << self
      def all
        DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS.all
          .reject { |type_record| type_record.deprecated.present? }
          .map { |type_record| new(type_record.to_h) }
      end

      def undergraduate
        all
          .select do |type|
            DfE::ReferenceData::Qualifications::QUALIFICATIONS
              .one(type.qualification)&.degree.in?(UNDERGRADUATE_LEVELS)
          end
      end

      def names
        all.map(&:name)
      end

      def find_by_name(name)
        return if name.blank?

        all.find { |type| type.name.downcase == name.downcase }
      end

      def find_by_abbreviation_or_name(value)
        all.find do |degree|
          degree.abbreviation == value || degree.name == value
        end
      end

      def find_by_hesa_code(code)
        all.find { |type| type.hesa_code.present? && type.hesa_code == code }
      end

      def master_hesa_codes
        all.select(&:master?).collect(&:hesa_code)
      end

      def bachelor_hesa_codes
        all.select(&:bachelor?).collect(&:hesa_code)
      end

      def where(level:)
        case level
        when :all
          all
        when :undergraduate
          select_degrees_by_level(UNDERGRADUATE_LEVELS)
        when :foundation
          select_degrees_by_level([:foundation])
        when :bachelor
          select_degrees_by_level([:bachelor])
        when :master
          select_degrees_by_level([:master])
        when :doctor
          select_degrees_by_level([:doctor])
        end
      end

    private

      def select_degrees_by_level(level)
        all
        .select do |type|
          DfE::ReferenceData::Qualifications::QUALIFICATIONS
            .one(type.qualification)&.degree.in?(level)
        end
      end
    end
  end
end
