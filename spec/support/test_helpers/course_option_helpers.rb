module CourseOptionHelpers
  def course_option_for_provider(provider:, course: nil, site: nil, study_mode: 'full_time', recruitment_cycle_year: CycleTimetable.current_year)
    course ||= build(:course, :open, provider:, recruitment_cycle_year:)
    site ||= build(:site, provider:)
    create(:course_option, course:, site:, study_mode:)
  end

  def course_option_for_provider_code(provider_code:)
    provider = Provider.find_by(code: provider_code) || create(:provider, code: provider_code)
    course = build(:course, :open, provider:)
    site = build(:site, provider:)
    create(:course_option, course:, site:)
  end

  def course_option_for_accredited_provider(provider:, accredited_provider:, recruitment_cycle_year: CycleTimetable.current_year, permissions_required: true)
    course = if permissions_required
               build(:course, :open, :with_provider_relationship_permissions, provider:, accredited_provider:, recruitment_cycle_year:)
             else
               build(:course, :open, provider:, accredited_provider:, recruitment_cycle_year:)
             end

    site = build(:site, provider:)
    create(:course_option, course:, site:)
  end
end
