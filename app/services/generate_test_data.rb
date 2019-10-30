class GenerateTestData
  def initialize(number_of_candidates, provider = nil)
    @number_of_candidates = number_of_candidates
    @provider = provider || fake_provider
  end

  def generate
    # delete_all doesn't work on `through` associations
    provider.application_choices.map(&:delete)

    number_of_candidates.times do
      application_form = FactoryBot.create(
        :completed_application_form,
        application_choices_count: 0,
      )

      # Most of the time generate an application with a single course choice,
      # and sometimes 2 or 3.
      [1, 1, 1, 1, 1, 1, 1, 2, 3].sample.times do
        FactoryBot.create(
          :application_choice,
          course_option: course_option,
          application_form: application_form,
          personal_statement: Faker::Lorem.paragraph(sentence_count: 5),
          status: 'application_complete',
        )
      end
    end
  end

private

  attr_reader :provider, :number_of_candidates

  def course_option
    FactoryBot.create(
      :course_option,
      course: random_course,
      site: random_site,
    )
  end

  def random_course
    FactoryBot.create(
      :course,
      provider: provider,
      code: random_code(Course, provider),
    )
  end

  def random_site
    FactoryBot.create(
      :site,
      provider: provider,
      code: random_code(Site, provider),
    )
  end

  def fake_provider
    Provider.find_or_create_by(
      name: 'Example Training Provider',
      code: 'ABC',
    )
  end

  def random_code(klass, provider)
    loop do
      code = Faker::Alphanumeric.alphanumeric(number: Course::CODE_LENGTH).upcase
      return code if klass.find_by(code: code, provider: provider).nil?
    end
  end
end
