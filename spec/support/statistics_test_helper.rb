module StatisticsTestHelper
  def generate_statistics_test_data
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'male', date_of_birth: date_of_birth(years_ago: 20), region_code: :north_east, candidate: hidden_candidate)
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'primary', program_type: 'higher_education_programme', region: 'eastern', subjects: [primary_subject(:mathematics)]),
           application_form: form)

    # Apply 1
    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'male', date_of_birth: date_of_birth(years_ago: 20), region_code: :north_east, phase: 'apply_1')
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'primary', program_type: 'school_direct_training_programme', region: 'eastern', subjects: [primary_subject(:mathematics)]),
           application_form: form)

    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 23), region_code: :north_west, phase: 'apply_1')
    create(:application_choice,
           :with_accepted_offer,
           course_option: course_option_with(level: 'primary', program_type: 'school_direct_salaried_training_programme', region: 'east_midlands', subjects: [primary_subject(:english)]),
           application_form: form)

    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 24), region_code: :yorkshire_and_the_humber, phase: 'apply_1')
    create(:application_choice,
           :with_offer,
           course_option: course_option_with(level: 'primary', program_type: 'pg_teaching_apprenticeship', region: 'london', subjects: [primary_subject(:geography_and_history)]),
           application_form: form)
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_with(level: 'primary', program_type: 'pg_teaching_apprenticeship', region: 'yorkshire_and_the_humber', subjects: [primary_subject(:geography_and_history)]),
           application_form: form)

    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'Prefer not to say', date_of_birth: date_of_birth(years_ago: 26), region_code: :east_midlands, phase: 'apply_1')
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_with(level: 'primary', program_type: 'scitt_programme', region: 'north_east', subjects: [primary_subject(:no_specialism)]),
           application_form: form)
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_with(level: 'primary', program_type: 'scitt_programme', region: 'north_west', subjects: [primary_subject(:mathematics)]),
           application_form: form)
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_with(level: 'primary', program_type: 'scitt_programme', region: 'south_east', subjects: [primary_subject(:english)]),
           application_form: form)

    declined_form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 31), region_code: :west_midlands, phase: 'apply_1')
    create(:application_choice,
           :with_declined_offer,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'north_west', subjects: [secondary_subject('Art and design'), secondary_subject('History')]),
           application_form: declined_form)

    # keep the country code nil so that this application falls into the "No region" bucket in the MonthlyStatisticsReport
    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, country: nil, sex: 'intersex', date_of_birth: date_of_birth(years_ago: 35), phase: 'apply_1')
    create(:application_choice,
           :withdrawn,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'south_east', subjects: [secondary_subject('English')]),
           application_form: form)

    rejected_form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 40), region_code: :eastern, phase: 'apply_1')
    create(:application_choice,
           :with_rejection,
           course_option: course_option_with(level: 'further_education', program_type: 'higher_education_programme', region: 'south_west'),
           application_form: rejected_form)

    rejected_form_multiple_choices = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 25), region_code: :south_west, phase: 'apply_1')
    create(:application_choice,
           :with_rejection,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'west_midlands', subjects: [secondary_subject('Mathematics')]),
           application_form: rejected_form_multiple_choices)
    create(:application_choice,
           :with_rejection,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'east_midlands', subjects: [secondary_subject('Mathematics')]),
           application_form: rejected_form_multiple_choices)

    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 66), region_code: :london, phase: 'apply_1')
    create(:application_choice,
           :with_withdrawn_offer,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'west_midlands', subjects: [secondary_subject('Psychology')]),
           application_form: form)

    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 66), region_code: :london, phase: 'apply_1')
    create(:application_choice,
           :with_deferred_offer,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'west_midlands', subjects: [secondary_subject('Psychology')]),
           application_form: form)

    # deferred app reinstated in this cycle
    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 66), region_code: :london, phase: 'apply_1', recruitment_cycle_year: RecruitmentCycle.previous_year)
    create(:application_choice,
           :withdrawn,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'west_midlands', subjects: [secondary_subject('German')]),
           current_recruitment_cycle_year: RecruitmentCycle.previous_year,
           application_form: form)
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'west_midlands', subjects: [secondary_subject('Geography'), secondary_subject('Economics')]),
           application_form: form)

    form = create(:application_form, :minimum_info, :with_equality_and_diversity_data, sex: 'female', date_of_birth: date_of_birth(years_ago: 26), region_code: :london, phase: 'apply_1', recruitment_cycle_year: RecruitmentCycle.current_year)
    create(:application_choice,
           :with_conditions_not_met,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'yorkshire_and_the_humber', subjects: [secondary_subject('Chemistry')]),
           application_form: form)

    # Apply again
    form = DuplicateApplication.new(declined_form, target_phase: 'apply_2').duplicate
    create(:application_choice,
           :unsubmitted,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'yorkshire_and_the_humber', subjects: [secondary_subject('Drama')]),
           application_form: form)

    form = DuplicateApplication.new(rejected_form, target_phase: 'apply_2').duplicate
    form.update(submitted_at: Time.zone.now)
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'yorkshire_and_the_humber', subjects: [secondary_subject('Russian')]),
           application_form: form)

    form = DuplicateApplication.new(rejected_form_multiple_choices, target_phase: 'apply_2').duplicate
    form.update(submitted_at: Time.zone.now)
    create(:application_choice,
           :withdrawn,
           course_option: course_option_with(level: 'secondary', program_type: 'higher_education_programme', region: 'yorkshire_and_the_humber', subjects: [secondary_subject('Physics')]),
           application_form: form)
  end

  def course_option_with(
    program_type:,
    region:,
    level:,
    subjects: []
  )
    create(:course_option,
           course: create(:course,
                          program_type: program_type,
                          level: level,
                          subjects: subjects.presence || create_list(:subject, 1),
                          provider: create(:provider,
                                           region_code: region)))
  end

  def primary_subject(specialism)
    name, code = {
      no_specialism: %w[Primary 00],
      english: ['Primary with English', '01'],
      geography_and_history: ['Primary with geography and history', '02'],
      mathematics: ['Primary with mathematics', '03'],
      modern_languages: ['Primary with modern languages', '04'],
      pe: ['Primary with physical education', '06'],
      science: ['Primary with science', '07'],
    }[specialism]

    Subject.find_by(name: name, code: code).presence || create(:subject, name: name, code: code)
  end

  def secondary_subject(name)
    code = { 'Art and design' => 'W1',
             'Science' => 'F0',
             'Biology' => 'C1',
             'Business studies' => '08',
             'Chemistry' => 'F1',
             'Citizenship' => '09',
             'Classics' => 'Q8',
             'Communication and media studies' => 'P3',
             'Computing' => '11',
             'Dance' => '12',
             'Design and technology' => 'DT',
             'Drama' => '13',
             'Economics' => 'L1',
             'English' => 'Q3',
             'Geography' => 'F8',
             'Health and social care' => 'L5',
             'History' => 'V1',
             'Mathematics' => 'G1',
             'Music' => 'W3',
             'Philosophy' => 'P1',
             'Physical education' => 'C6',
             'Physics' => 'F3',
             'Psychology' => 'C8',
             'Religious education' => 'V6',
             'Social sciences' => '14',
             'French' => '15',
             'English as a second or other language' => '16',
             'German' => '17',
             'Italian' => '18',
             'Japanese' => '19',
             'Mandarin' => '20',
             'Russian' => '21',
             'Spanish' => '22',
             'Modern languages (other)' => '24' }.fetch(name)

    Subject.find_by(name: name, code: code).presence || create(:subject, name: name, code: code)
  end

  def expect_report_rows(column_headings:)
    expected_rows = yield.map { |row| column_headings.zip(row).to_h } # [['Status', 'Recruited'], ['First Application', 1] ...].to_h
    expect(statistics[:rows]).to match_array expected_rows
  end

  def expect_column_totals(*totals)
    expect(statistics[:column_totals]).to eq totals
  end

  def date_of_birth(years_ago:)
    years_ago.years.ago
  end
end
