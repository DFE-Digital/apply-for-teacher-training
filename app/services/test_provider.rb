class TestProvider
  def self.find_or_create
    Provider.default_scoped.find_or_create_by(code: 'TEST') do |provider|
      provider.name = 'Test Provider'
    end
  end

  def self.training_courses
    test_provider = find_or_create

    existing_courses = test_provider.courses.joins(:course_options).where(
      open_on_apply: true,
      recruitment_cycle_year: RecruitmentCycle.current_year,
    )

    return existing_courses if existing_courses.count >= 3

    new_test_courses = FactoryBot.create_list(:course, 3, :open_on_apply, provider: test_provider)
    new_test_courses.each do |course|
      create_course_option_for(course)
    end

    existing_courses.reload
  end

  def self.create_course_option_for(course)
    FactoryBot.create(:course_option, course: course)
  end

  private_class_method :create_course_option_for
end
