class Factory::ApplicationChoice < Satisfactory::Record
  PERMITTED_WITHOUT_COUNT = %i[part_time rejected course_option].freeze

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

  def course_option(new_record: false)
    if new_record || @course_option.nil?
      @course_option = Factory::CourseOption.new(upstream: self)
    else
      @course_option
    end
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

  def permitted_without_count
    PERMITTED_WITHOUT_COUNT
  end
end
