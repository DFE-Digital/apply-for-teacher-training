require 'rails_helper'

RSpec.describe GetChangeOfferOptions do
  include CourseOptionHelpers

  let(:for_provider) { create(:provider) }
  let(:course) { create(:course, :open_on_apply, provider: for_provider) }
  let(:accredited_course) { create(:course, :open_on_apply, accredited_provider: for_provider) }
  let(:provider_user) { create(:provider_user) }

  let(:service) do
    GetChangeOfferOptions.new(
      user: provider_user,
      for_provider: for_provider,
      recruitment_cycle_year: RecruitmentCycle.current_year,
    )
  end

  def allow_all_providers_to_make_decisions(training_provider, ratifying_provider)
    create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
      training_provider_can_make_decisions: true,
      ratifying_provider_can_make_decisions: true,
    )
  end

  describe '#make_decisions_courses' do
    it 'returns courses run or ratified by the user\'s providers' do
      allow_all_providers_to_make_decisions(accredited_course.provider, accredited_course.accredited_provider)
      provider_user.providers << for_provider
      provider_user.provider_permissions.update_all(make_decisions: true)
      expect(service.make_decisions_courses).to match_array([course, accredited_course])
    end

    it 'only returns courses for which the user has make_decisions permission' do
      allow_all_providers_to_make_decisions(accredited_course.provider, accredited_course.accredited_provider)
      new_course = create(:course, :open_on_apply)
      provider_user.providers << [for_provider, new_course.provider]
      provider_user.provider_permissions.first.update(make_decisions: true)
      expect(service.make_decisions_courses).to match_array([course, accredited_course])
    end

    it 'excludes courses for which the user lacks org-level make_decisions' do
      provider_user.providers << for_provider
      provider_user.provider_permissions.first.update(make_decisions: true)
      expect(service.make_decisions_courses.count).to eq(0)
    end
  end

  describe '#offerable_courses' do
    it 'returns only courses which are open on apply' do; end

    it 'returns only courses which are in the same recruitment cycle' do; end

    it 'returns ratified courses accredited by the same provider' do; end

    it 'returns self-ratified courses accredited by the same provider' do; end
  end

  describe '#available_providers' do
    it 'does not return duplicate providers' do
      allow_all_providers_to_make_decisions(accredited_course.provider, accredited_course.accredited_provider)
      provider_user.providers << for_provider
      provider_user.provider_permissions.first.update(make_decisions: true)
      create(
        :course,
        :open_on_apply,
        provider: accredited_course.provider,
        accredited_provider: for_provider
      )
      expect(service.available_providers).to eq([accredited_course.provider])
    end
  end
end
