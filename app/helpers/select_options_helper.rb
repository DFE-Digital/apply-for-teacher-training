module SelectOptionsHelper
  Option = Struct.new(:id, :name)
  CollectionOption = Struct.new(:value, :text)

  def select_nationality_options(include_british_and_irish: false)
    [
      Option.new('', t('application_form.personal_details.nationality.default_option')),
    ] + nationality_options(include_british_and_irish:).map { |_, nationality| Option.new(nationality, nationality) }
  end

  def select_country_options
    [
      Option.new('', t('application_form.contact_details.country.default_option')),
    ] + COUNTRIES_AND_TERRITORIES.except('GB').map { |iso3166, country| Option.new(iso3166, country) }
  end

  def select_degree_country_options
    [
      Option.new('', ''),
    ] + COUNTRIES_AND_TERRITORIES.except('GB').map { |iso3166, country| Option.new(iso3166, country) }
  end

  def select_course_options(courses)
    [
      Option.new('', t('activemodel.errors.models.candidate_interface/pick_course_form.attributes.course_id.blank')),
    ] + courses.map { |course| Option.new(course.id, course.name) }
  end

  def select_provider_options(providers)
    [
      Option.new('', t('activemodel.errors.models.candidate_interface/pick_provider_form.attributes.provider_id.blank')),
    ] + providers.map { |provider| Option.new(provider.id, "#{provider.name} (#{provider.code})") }
  end

  def select_sort_options
    sort_options = [
      [ValidationErrorSummaryQuery::ALL_TIME, 'All time'],
      [ValidationErrorSummaryQuery::LAST_WEEK, 'Last week'],
      [ValidationErrorSummaryQuery::LAST_MONTH, 'Last month'],
    ]
    sort_options.map { |sort_option| CollectionOption.new(sort_option.first, sort_option.last) }
  end

private

  def nationality_options(include_british_and_irish:)
    include_british_and_irish ? NATIONALITIES : NATIONALITIES.except('GB', 'IE')
  end
end
