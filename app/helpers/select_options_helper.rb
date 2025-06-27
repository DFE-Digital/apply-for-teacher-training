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

  def select_course_options_with_provider_name(courses)
    multiple_providers = current_provider_user.providers.many?

    course_options = courses.map do |course|
      if multiple_providers
        Option.new(course.id, course.name_code_and_course_provider)
      else
        Option.new(course.id, course.name_and_code)
      end
    end

    [
      Option.new('', t('activemodel.errors.models.candidate_interface/pick_course_form.attributes.course_id.blank')),
    ] + course_options
  end

  def collection_course_options_with_provider_name
    if current_provider_user.providers.many?
      :name_code_and_course_provider
    else
      :name_and_code
    end
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
    # rubocop:disable Style/HashExcept
    include_british_and_irish ? NATIONALITIES : NATIONALITIES.reject { |iso_code, _| %w[GB IE].include?(iso_code) }
    # rubocop:enable Style/HashExcept
  end
end
