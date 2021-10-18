module SelectOptionsHelper
  def select_nationality_options(include_british_and_irish: false)
    [
      OpenStruct.new(id: '', name: t('application_form.personal_details.nationality.default_option')),
    ] + nationality_options(include_british_and_irish: include_british_and_irish).map { |_, nationality| OpenStruct.new(id: nationality, name: nationality) }
  end

  def select_country_options
    [
      OpenStruct.new(id: '', name: t('application_form.contact_details.country.default_option')),
    ] + COUNTRIES_AND_TERRITORIES.except('GB').map { |iso3166, country| OpenStruct.new(id: iso3166, name: country) }
  end

  def select_course_options(courses)
    [
      OpenStruct.new(id: '', name: t('activemodel.errors.models.candidate_interface/pick_course_form.attributes.course_id.blank')),
    ] + courses.map { |course| OpenStruct.new(id: course.id, name: course.name) }
  end

  def select_provider_options(providers)
    [
      OpenStruct.new(id: '', name: t('activemodel.errors.models.candidate_interface/pick_provider_form.attributes.provider_id.blank')),
    ] + providers.map { |provider| OpenStruct.new(id: provider.id, name: "#{provider.name} (#{provider.code})") }
  end

  def select_sort_options
    sort_options = [
      [ValidationErrorSummaryQuery::ALL_TIME, 'All time'],
      [ValidationErrorSummaryQuery::LAST_WEEK, 'Last week'],
      [ValidationErrorSummaryQuery::LAST_MONTH, 'Last month'],
    ]
    sort_options.map { |sort_option| OpenStruct.new(value: sort_option.first, text: sort_option.last) }
  end

private

  def nationality_options(include_british_and_irish:)
    include_british_and_irish ? NATIONALITIES : NATIONALITIES.reject { |iso_code, _| %w[GB IE].include?(iso_code) }
  end
end
