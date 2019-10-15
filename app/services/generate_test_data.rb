class GenerateTestData
  def generate(number_of_candidates = 100)
    Candidate.delete_all

    number_of_candidates.times do
      application_form = FactoryBot.create(
        :application_form,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
      )

      # Most of the time generate a application with a single course choice,
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

  def random_course
    FactoryBot.create(
      :course,
      provider: provider,
    )
  end

  def provider
    Provider.find_or_create_by(
      name: 'Example Training Provider',
      code: 'ABC',
    )
  end
end
