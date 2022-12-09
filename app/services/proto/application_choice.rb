class Proto::ApplicationChoice < Proto::Record
  def initialize(...)
    super
    @course_option = nil
  end

  def part_time
    modify do |ac|
      ac.with.course_option.part_time
    end
  end

  def rejected
    tap do |ac|
      ac.traits << :with_rejection
    end
  end

  def course_option
    @course_option ||= Proto::CourseOption.new(upstream: self)
  end

  def build
    FactoryBot.build(:application_choice, *traits, **attributes)
  end

private

  def attributes(action = :build)
    {}.tap do |attrs|
      attrs[:course_option] = @course_option.public_send(action) if @course_option
    end
  end

  def associations_plan
    attributes(:build_plan)
  end
end
