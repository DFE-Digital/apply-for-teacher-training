class TestProvider
  def self.find_or_create
    Provider.default_scoped.find_or_create_by(code: 'TEST') do |provider|
      provider.name = 'Test Provider'
    end
  end

  def self.training_courses(previous_cycle)
    test_provider = find_or_create

    existing_courses = test_provider.courses.joins(:course_options).where(
      recruitment_cycle_year: recruitment_cycle_year(previous_cycle),
    )

    return existing_courses if existing_courses.count >= 3

    new_test_courses = generate_courses(previous_cycle, test_provider)
    new_test_courses.each do |course|
      create_course_option_for(course)
    end

    existing_courses.reload
  end

  def self.recruitment_cycle_year(previous_cycle)
    if previous_cycle
      RecruitmentCycleTimetable.previous_year
    else
      RecruitmentCycleTimetable.current_year
    end
  end

  def self.generate_courses(previous_cycle, test_provider)
    trait = previous_cycle ? :previous_year : :open
    FactoryBot.create_list(:course, 3, trait, provider: test_provider)
  end

  def self.create_course_option_for(course)
    FactoryBot.create(:course_option, course:)
  end

  private_class_method :create_course_option_for
end
