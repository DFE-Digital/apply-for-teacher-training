module CourseOptionHelpers
  def course_option_for_provider(provider:, course: nil, site: nil, study_mode: 'full_time', recruitment_cycle_year: RecruitmentCycle.current_year)
    course ||= build(:course, :open_on_apply, provider:, recruitment_cycle_year:)
    site ||= build(:site, provider:)
    create(:course_option, course:, site:, study_mode:)
  end

  def course_option_for_provider_code(provider_code:)
    provider = create(:provider, :with_signed_agreement, code: provider_code)
    course = build(:course, :open_on_apply, provider:)
    site = build(:site, provider:)
    create(:course_option, course:, site:)
  end

  def course_option_for_accredited_provider(provider:, accredited_provider:, recruitment_cycle_year: RecruitmentCycle.current_year)
    course = build(:course, :open_on_apply, :with_provider_relationship_permissions, provider:, accredited_provider:, recruitment_cycle_year:)
    site = build(:site, provider:)
    create(:course_option, course:, site:)
  end
end
