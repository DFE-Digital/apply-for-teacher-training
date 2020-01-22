module CourseOptionHelpers
  def course_option_for_provider(provider:)
    course = create(:course, provider: provider)
    site = create(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end

  def course_option_for_provider_code(provider_code:)
    provider = create(:provider, :with_signed_agreement, code: provider_code)
    course = create(:course, provider: provider)
    site = create(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end

  def course_option_for_accrediting_provider(provider:, accrediting_provider:)
    course = create(:course, provider: provider, accrediting_provider: accrediting_provider)
    site = create(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end
end
