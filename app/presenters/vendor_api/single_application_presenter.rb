module VendorApi
  class SingleApplicationPresenter < SimpleDelegator
    def as_json
      {
        id: id.to_s,
        type: 'application',
        attributes: {
          status: status,
          updated_at: updated_at.iso8601,
          submitted_at: submitted_at.iso8601,
          personal_statement: personal_statement,
          candidate: {
            first_name: first_name,
            last_name: last_name,
            date_of_birth: date_of_birth,
            nationality: nationalities,
            uk_residency_status: uk_residency_status,
            english_main_language: english_main_language,
            english_language_qualifications: english_language_details,
            other_languages: other_language_details,
            disability_disclosure: 'I have difficulty climbing stairs',
          },
          contact_details: {
            phone_number: phone_number,
            address_line1: address_line1,
            address_line2: address_line2,
            address_line3: address_line3,
            address_line4: address_line4,
            postcode: postcode,
            country: country,
            email: candidate.email_address,
          },
          course: course,
          qualifications: {
            gcses: [
              {
                qualification_type: 'GCSE',
                subject: 'Maths',
                grade: 'A',
                award_year: '2001',
                equivalency_details: nil,
                institution_details: nil,
              },
              {
                qualification_type: 'GCSE',
                subject: 'English',
                grade: 'A',
                award_year: '2001',
                equivalency_details: nil,
                institution_details: nil,
              },
            ],
            degrees: [
              {
                qualification_type: 'BA',
                subject: 'Geography',
                grade: '2.1',
                award_year: '2007',
                equivalency_details: nil,
                institution_details: 'Imperial College London',
              },
            ],
            other_qualifications: [
              {
                qualification_type: 'A Level',
                subject: 'Chemistry',
                grade: 'B',
                award_year: '2004',
                equivalency_details: nil,
                institution_details: 'Harris Westminster Sixth Form',
              },
            ],
          },
          references: [
            {
              name: 'John Smith',
              email: 'johnsmith@example.com',
              phone_number: '07999 111111',
              relationship: 'BA Geography course director at Imperial College. I tutored the candidate for one academic year.',
              confirms_safe_to_work_with_children: true,
              reference: <<~HEREDOC,
                Fantastic personality. Great with people. Strong communicator .  Excellent character. Passionate about teaching . Great potential.  A charismatic talented able young person who is far better than her official degree result. An exceptional person.

                Passion for their subject	7 / 10
                Knowledge about their subject	10 / 10
                General academic performance	9 / 10
                Ability to meet deadlines and organise their time	7 / 10
                Ability to think critically	10 / 10
                Ability to work collaboratively	Don’t know
                Mental and emotional resilience	8 / 10
                Literacy	9 / 10
                Numeracy	7 / 10
              HEREDOC
            },
            {
              name: 'Jane Brown',
              email: 'janebrown@example.com',
              phone_number: '07111 999999',
              relationship: 'Headmistress at Harris Westminster Sixth Form',
              confirms_safe_to_work_with_children: true,
              reference: <<~HEREDOC,
                An ideal teacher. Brisk and lively communicator. Intelligent and self-aware. Good with children. Led education outreach workshops.

                Passion for their subject	7 / 10
                Knowledge about their subject	10 / 10
                General academic performance	9 / 10
                Ability to meet deadlines and organise their time	7 / 10
                Ability to think critically	10 / 10
                Ability to work collaboratively	Don’t know
                Mental and emotional resilience	8 / 10
                Literacy	9 / 10
                Numeracy	7 / 10
              HEREDOC
            },
          ],
          work_experience: {
            jobs: work_experience_jobs,
            volunteering: work_experience_volunteering,
          },
          offer: offer,
          rejection: get_rejection,
          withdrawal: nil,
          hesa_itt_data: {
            sex: '',
            disability: '',
            ethnicity: '',
          },
          further_information: further_information,
        },
      }
    end

  private

    def get_rejection
      if rejection_reason?
        {
          reason: rejection_reason,
        }
      end
    end

    def nationalities
      [
        first_nationality,
        second_nationality,
      ].map { |n|
        NATIONALITIES.to_h.invert[n]
      }.compact
    end

    def course
      {
        start_date: super.start_date,
        provider_ucas_code: provider.code,
        site_ucas_code: site.code,
        course_ucas_code: super.code,
      }
    end

    def work_experience_jobs
      application_work_experiences.map do |experience|
        experience_to_hash(experience)
      end
    end

    def work_experience_volunteering
      application_volunteering_experiences.map do |experience|
        experience_to_hash(experience)
      end
    end

    def experience_to_hash(experience)
      {
        start_date: experience.start_date.to_date,
        end_date: experience.end_date&.to_date,
        role: experience.role,
        organisation_name: experience.organisation,
        working_with_children: experience.working_with_children,
        commitment: experience.commitment,
        description: experience.details,
      }
    end
  end
end
