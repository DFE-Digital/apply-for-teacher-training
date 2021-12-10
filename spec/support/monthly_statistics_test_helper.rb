module MonthlyStatisticsTestHelper
  def generate_monthly_statistics_test_data
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    form = create(:application_form, candidate: hidden_candidate)
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(program_type: 'higher_education_programme', region: 'eastern'),
           application_form: form)

    # Apply 1
    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(program_type: 'school_direct_training_programme', region: 'eastern'),
           application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :with_accepted_offer,
           course_option: course_option_with(program_type: 'school_direct_salaried_training_programme', region: 'east_midlands'),
           application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :with_offer,
           course_option: course_option_with(program_type: 'pg_teaching_apprenticeship', region: 'london'),
           application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_with(program_type: 'scitt_programme', region: 'north_east'),
           application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :with_declined_offer,
           course_option: course_option_with(program_type: 'higher_education_programme', region: 'north_west'),
           application_form: form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :withdrawn,
           course_option: course_option_with(program_type: 'higher_education_programme', region: 'south_east'),
           application_form: form)

    rejected_form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :with_rejection,
           course_option: course_option_with(program_type: 'higher_education_programme', region: 'south_west'),
           application_form: rejected_form)

    form = create(:application_form, phase: 'apply_1')
    create(:application_choice,
           :with_deferred_offer,
           # course_option: course_option_with(program_type: 'higher_education_programme', region: 'west_midlands'),
           application_form: form)

    # Apply 2
    form = DuplicateApplication.new(rejected_form, target_phase: 'apply_2').duplicate
    create(:application_choice,
           :with_recruited,
           course_option: course_option_with(program_type: 'higher_education_programme', region: 'yorkshire_and_the_humber'),
           application_form: form)
  end

  def course_option_with(program_type: 'higher_education_programme', region: 'eastern')
    create(:course_option,
           course: create(:course,
                          program_type: program_type,
                          provider: create(:provider,
                                           region_code: region)))
  end

  def expect_report_rows(column_headings:)
    expected_rows = yield.map { |row| column_headings.zip(row).to_h } # [['Status', 'Recruited'], ['First Application', 1] ...].to_h
    expect(statistics[:rows]).to match_array expected_rows
  end

  def expect_column_totals(*totals)
    expect(statistics[:column_totals]).to eq totals
  end
end
