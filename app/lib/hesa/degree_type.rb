module Hesa
  class DegreeType
    include ActiveModel::Model
    attr_accessor :id, :priority, :qualification, :topic, :synonyms, :dqt_id, :hesa_code, :abbreviation, :name, :deprecated
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
        all.find { |type| type.name == name }
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

    private

      def select_degrees_by_level(level)
        all
        .select { |type| DfE::ReferenceData::Qualifications::QUALIFICATIONS.one(type.qualification)&.degree.in?(level) }
        .map { |type| "#{type.abbreviation}|#{type.name}" }
      end
    end
  end
end
