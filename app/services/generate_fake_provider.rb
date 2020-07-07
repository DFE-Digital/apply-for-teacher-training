class GenerateFakeProvider
  def self.generate_provider(provider)
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    Provider.find_or_create_by(provider) do |new_provider|
      generate_courses_for(new_provider)
      generate_ratified_courses_for(new_provider) unless new_provider.code == 'TEST'
    end
  end

  def self.generate_courses_for(training_provider)
    10.times do
      FactoryBot.create(
        :course,
        provider: training_provider,
        code: Faker::Alphanumeric.alphanumeric(number: Course::CODE_LENGTH).upcase,
      )
    end
  end

  def self.generate_ratified_courses_for(ratifying_provider)
    test_provider = Provider.default_scoped.find_or_create_by(name: 'Test Provider', code: 'TEST')

    3.times do
      FactoryBot.create(
        :course,
        provider: test_provider,
        accredited_provider_id: ratifying_provider.id,
        code: Faker::Alphanumeric.unique.alphanumeric(number: Course::CODE_LENGTH).upcase,
      )
    end
  end

  private_class_method :generate_ratified_courses_for, :generate_courses_for
end
