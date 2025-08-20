module StatisticsTestHelper
  def generate_statistics_test_data
    original_counts = {
      ApplicationChoice => ApplicationChoice.count,
      ApplicationForm => ApplicationForm.count,
      Candidate => Candidate.count,
      CourseOption => CourseOption.count,
      Course => Course.count,
      Offer => Offer.count,
      Provider => Provider.count,
    }.freeze

    candidate = form = nil

    load_test_data.each do |entry|
      if entry.fetch(:date_of_birth_years_ago).present?
        candidate = create_and_advance(:candidate, **candidate_attrs(entry))
        form = create_and_advance(:application_form, :minimum_info, :with_equality_and_diversity_data, candidate:, **form_attrs(entry))
      end

      create_and_advance(:application_choice, entry.fetch(:status),
                         application_form: form,
                         course_option: build(:course_option,
                                              course: build(:course, **course_attrs(entry))))
    end

    expected_new_record_counts = {
      ApplicationChoice => 31,
      ApplicationForm => 24,
      Candidate => 17,
      CourseOption => 31,
      Course => 31,
      Offer => 11,
      Provider => 31,
    }.freeze

    errors = expected_new_record_counts.each.with_object([]) do |(model, expected_increase), array|
      actual_increase = model.count - original_counts.fetch(model)

      if actual_increase != expected_increase
        array << "Expected #{model.name} count to increase by #{expected_increase} but it increased by #{actual_increase}"
      end
    end

    if errors.any?
      raise <<~ERROR
        #{errors.join("\n")}

        If this is unexpected, check any changes you've made to the factories that might have generated more records.
        If this is expected, update the expected counts above.
      ERROR
    end
  end

  def create_and_advance(...)
    create(...).tap { TestSuiteTimeMachine.advance }
  end

  def load_subjects(level)
    CSV.table(File.expand_path("./data/#{level}_subjects.csv", __dir__), strip: true).each_with_object({}) do |row, hash|
      hash[row[:name]] = Subject.find_by(row.to_h).presence || create(:subject, row.to_h)
    end
  end

  def load_test_data
    CSV.table(File.expand_path('./data/statistics_test_data.csv', __dir__), strip: true)
  end

  def candidate_attrs(entry)
    { hide_in_reporting: (entry.fetch(:hide_in_reporting) == 'true') }.compact_blank
  end

  def form_attrs(entry)
    {
      date_of_birth: date_of_birth(years_ago: entry.fetch(:date_of_birth_years_ago)),
      recruitment_cycle_year: form_cycle(entry),
      region_code: entry.fetch(:candidate_region),
      sex: entry.fetch(:sex),
    }.compact_blank
  end

  def course_attrs(entry)
    {
      level: entry.fetch(:level),
      program_type: entry.fetch(:program_type),
      provider: build(:provider, **provider_attrs(entry)),
      recruitment_cycle_year: course_cycle(entry),
      course_subjects: (entry.fetch(:primary_subjects) || '').split('|').map { |name| build(:course_subject, subject: primary_subjects.fetch(name)) } +
        (entry.fetch(:secondary_subjects) || '').split('|').map { |name| build(:course_subject, subject: secondary_subjects.fetch(name)) },
    }.compact_blank
  end

  def provider_attrs(entry)
    { region_code: entry.fetch(:provider_region) }.compact_blank
  end

  def form_cycle(entry)
    recruitment_cycle_year(entry.fetch(:form_cycle))
  end

  def course_cycle(entry)
    recruitment_cycle_year(entry.fetch(:course_cycle))
  end

  def recruitment_cycle_year(year)
    return if year.blank?

    # year is either current, previous or next, not an integer value
    RecruitmentCycleTimetable.public_send("#{year}_year")
  end

  def primary_subjects
    @primary_subjects ||= load_subjects('primary')
  end

  def secondary_subjects
    @secondary_subjects ||= load_subjects('secondary')
  end

  def expect_report_rows(column_headings:)
    expected_rows = yield.map { |row| column_headings.zip(row).to_h } # [['Status', 'Recruited'], ['First Application', 1] ...].to_h
    expect(statistics[:rows]).to match_array expected_rows
  end

  def expect_column_totals(*totals)
    expect(statistics[:column_totals]).to eq totals
  end

  def date_of_birth(years_ago:)
    return if years_ago.blank?

    Date.new(RecruitmentCycleTimetable.current_year - years_ago, 1, 1)
  end
end
