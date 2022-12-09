class Proto::CourseOption < Proto::Record
  def part_time
    tap do |co|
      co.traits << :part_time
    end
  end

  def build
    FactoryBot.build(:course_option, *traits)
  end
end
