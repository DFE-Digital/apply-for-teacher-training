class GenerateFakeProvider
  def self.generate_provider(provider)
    raise 'You cannot generate test data in production' if HostingEnvironment.production?

    Provider.find_or_create_by(provider) do |new_provider|
      generate_courses_for(new_provider)
      generate_ratified_courses_for(new_provider) unless new_provider.code == 'TEST'
    end
  end

  def self.generate_courses_for(training_provider)
    unique_course_codes(10).each do |code|
      generate_course_options_for FactoryBot.create(
        :course,
        :open_on_apply,
        :with_both_study_modes,
        provider: training_provider,
        code: code,
      )
    end
  end

  def self.generate_ratified_courses_for(ratifying_provider)
    test_provider = TestProvider.find_or_create

    unique_course_codes(3).each do |code|
      generate_course_options_for FactoryBot.create(
        :course,
        :open_on_apply,
        :with_both_study_modes,
        provider: test_provider,
        accredited_provider_id: ratifying_provider.id,
        code: code,
      )
    end

    generate_provider_permissions_for(test_provider, ratifying_provider)
  end

  def self.generate_course_options_for(course)
    FactoryBot.create(:course_option, :full_time, course: course)
    FactoryBot.create(:course_option, :part_time, course: course)
    FactoryBot.create(:course_option, :no_vacancies, course: course)
  end

  def self.unique_course_codes(number = 3)
    course_codes = []

    while course_codes.uniq.count < number
      code = Faker::Alphanumeric.unique.alphanumeric(number: Course::CODE_LENGTH).upcase
      course_codes << code
    end

    course_codes.uniq
  end

  def self.generate_provider_permissions_for(provider, ratifying_provider)
    ProviderRelationshipPermissions.find_or_create_by!(
      training_provider: provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
      setup_at: Time.zone.now,
    )
  end

  private_class_method :generate_ratified_courses_for,
                       :generate_courses_for,
                       :generate_course_options_for,
                       :generate_provider_permissions_for
end
