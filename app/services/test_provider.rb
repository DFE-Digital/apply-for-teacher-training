class TestProvider
  def self.find_or_create
    Provider.default_scoped.find_or_create_by(code: 'TEST') do |provider|
      provider.name = 'Test Provider'
    end
  end

  def self.training_courses(previous_cycle)
    test_provider = find_or_create

    existing_courses = test_provider.courses.joins(:course_options).where(
      open_on_apply: !previous_cycle,
      recruitment_cycle_year: recruitment_cycle_year(previous_cycle),
    )

    return existing_courses if existing_courses.count >= 3

    new_test_courses = generate_courses(previous_cycle, test_provider)
    new_test_courses.each do |course|
      create_course_option_for(course)
    end

    existing_courses.reload
  end

  def self.create_course_option_for(course)
    FactoryBot.create(:course_option, course: course)
  end

  private_class_method :create_course_option_for

  def self.recruitment_cycle_year(previous_cycle)
    if previous_cycle
      RecruitmentCycle.previous_year
    else
      RecruitmentCycle.current_year
    end
  end

  private_class_method :recruitment_cycle_year

  def self.generate_courses(previous_cycle, test_provider)
    if previous_cycle
      FactoryBot.create_list(:course, 3, :previous_year, provider: test_provider)
    else
      FactoryBot.create_list(:course, 3, :open_on_apply, provider: test_provider)
    end
  end
end
