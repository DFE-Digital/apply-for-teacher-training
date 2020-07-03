module Hesa
  class Grade
    GradeStruct = Struct.new(:hesa_code, :description, :visual_grouping)

    class << self
      def all
        HESA_DEGREE_GRADES.map { |grade_data| GradeStruct.new(*grade_data) }
      end

      def main
        all.select { |g| g.visual_grouping == :main }
      end

      def other
        all.select { |g| g.visual_grouping == :other }
      end

      def find_by_description(description)
        all.find { |g| g.description == description }
      end

      def find_by_hesa_code(hesa_code)
        all.find { |g| g.hesa_code == hesa_code }
      end
    end
  end
end
