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
          provider_ucas_code: random_ucas_org,
          course_ucas_code: course_ucas_code,
          application_form: application_form,
          personal_statement: Faker::Lorem.paragraph(sentence_count: 5),
        )
      end
    end
  end

private

  def random_ucas_org
    # Make 90% of the applications belong to the ABC org, so that we can
    # test the API with a known `provider_ucas_code`
    rand(100) > 10 ? 'ABC' : SecureRandom.hex(2).upcase
  end

  def course_ucas_code
    SecureRandom.hex(2).upcase
  end
end
