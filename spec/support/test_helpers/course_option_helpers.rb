module CourseOptionHelpers
  def course_option_for_provider(provider:, course: nil, site: nil, study_mode: 'full_time', recruitment_cycle_year: RecruitmentCycle.current_year)
    course ||= build(:course, :open_on_apply, provider: provider, recruitment_cycle_year: recruitment_cycle_year)
    site ||= build(:site, provider: provider)
    create(:course_option, course: course, site: site, study_mode: study_mode)
  end

  def course_option_for_provider_code(provider_code:)
    provider = create(:provider, :with_signed_agreement, code: provider_code)
    course = build(:course, :open_on_apply, provider: provider)
    site = build(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end

  def course_option_for_accredited_provider(provider:, accredited_provider:, recruitment_cycle_year: RecruitmentCycle.current_year)
    course = build(:course, :open_on_apply, :with_provider_relationship_permissions, provider: provider, accredited_provider: accredited_provider, recruitment_cycle_year: recruitment_cycle_year)
    site = build(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end
end
