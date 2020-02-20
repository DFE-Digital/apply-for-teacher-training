module SelectOptionsHelper
  def select_nationality_options
    [
      OpenStruct.new(id: '', name: t('application_form.personal_details.nationality.default_option')),
    ] + NATIONALITIES.map { |_, nationality| OpenStruct.new(id: nationality, name: nationality) }
  end

  def select_course_options(courses)
    [
      OpenStruct.new(id: '', name: t('activemodel.errors.models.candidate_interface/pick_course_form.attributes.code.blank')),
    ] + courses.map { |course| OpenStruct.new(id: course.id, name: "#{course.name} (#{course.code})") }
  end

  def select_provider_options(providers)
    [
      OpenStruct.new(id: '', name: t('activemodel.errors.models.candidate_interface/pick_provider_form.attributes.code.blank')),
    ] + providers.map { |provider| OpenStruct.new(id: provider.id, name: "#{provider.name} (#{provider.code})") }
  end
end
