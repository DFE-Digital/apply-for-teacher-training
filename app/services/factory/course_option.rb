class Factory::CourseOption < Satisfactory::Record
  PERMITTED_WITHOUT_COUNT = %i[part_time].freeze

  def part_time
    tap do |co|
      co.traits << :part_time
    end
  end

  def build
    FactoryBot.build(:course_option, *traits)
  end

private

  def permitted_without_count
    PERMITTED_WITHOUT_COUNT
  end
end
