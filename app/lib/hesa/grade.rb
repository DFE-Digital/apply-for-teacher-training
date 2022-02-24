module Hesa
  class Grade
    include ActiveModel::Model
    attr_accessor :id, :name, :hesa_code, :visual_grouping
    alias group= visual_grouping=
    alias description= name=
    alias description name

    class << self
      def all
        DfE::ReferenceData::Degrees::GRADES.all.map { |grade_data| new(grade_data.to_h) }
      end

      def find_by_description(description)
        all.find { |g| g.description == description }
      end

      def find_by_hesa_code(hesa_code)
        all.find { |g| g.hesa_code == hesa_code }
      end

      def main_grouping
        all.select { |g| g.visual_grouping.in? %i[main_undergrad main_postgrad] }
      end

      def undergrad_grouping_only
        all.select { |g| g.visual_grouping.in? %i[main_undergrad] }
      end

      def other_grouping
        all.select { |g| g.visual_grouping == :other }
      end

      def grouping_for(degree_type_code:)
        degree_type = Hesa::DegreeType.find_by_hesa_code(degree_type_code)

        if degree_type&.bachelor?
          undergrad_grouping_only
        else
          main_grouping
        end
      end
    end
  end
end
