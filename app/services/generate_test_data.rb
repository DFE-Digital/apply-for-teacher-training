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
        :application_form,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
      )

      # Most of the time generate an application with a single course choice,
      # and sometimes 2 or 3.
      [1, 1, 1, 1, 1, 1, 1, 2, 3].sample.times do
        FactoryBot.create(
          :application_choice,
          course: random_course,
          application_form: application_form,
          personal_statement: Faker::Lorem.paragraph(sentence_count: 5),
        )
      end
    end
  end

private

  attr_reader :provider, :number_of_candidates

  def random_course
    FactoryBot.create(
      :course,
      provider: provider,
    )
  end

  def fake_provider
    Provider.find_or_create_by(
      name: 'Example Training Provider',
      code: 'ABC',
    )
  end
end
