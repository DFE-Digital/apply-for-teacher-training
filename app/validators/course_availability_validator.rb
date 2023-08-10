class CourseAvailabilityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    if application_choice.current_course.full?
      record.errors.add(attribute, :course_full)
      record.errors.add(attribute, :remove_or_change_application)
    end

    if application_choice.current_course_option.site_still_valid.blank?
      record.errors.add(attribute, :site_invalid)
      record.errors.add(attribute, :provider_recommendation, message: "#{application_choice.current_provider.name} may be able to also recommend an alternative course.")
    end

    if application_choice.current_course.exposed_in_find.blank?
      record.errors.add(attribute, :site_invalid)
    end
  end
end
