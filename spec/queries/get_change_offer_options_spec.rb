require 'rails_helper'

RSpec.describe GetChangeOfferOptions do
  include CourseOptionHelpers

  let(:course) { create(:course, :open_on_apply) }
  let(:accredited_course) { create(:course, :with_accredited_provider, :open_on_apply) }
  let(:provider_user) { create(:provider_user) }
  let(:application_choice) { create(:application_choice, :with_offer, course_option: create(:course_option, course: accredited_course)) }

  let(:service) do
    GetChangeOfferOptions.new(
      application_choice: application_choice,
      user: provider_user,
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

  describe '#available_providers' do
    it 'returns training providers for courses run or ratified by the user\'s providers' do
      allow_all_providers_to_make_decisions(accredited_course.provider, accredited_course.accredited_provider)
      provider_user.providers << [course.provider, accredited_course.accredited_provider]
      provider_user.provider_permissions.update_all(make_decisions: true)
      expect(service.available_providers).to match_array([course.provider, accredited_course.provider])
    end

    it 'only returns providers for which the user has make_decisions permission' do
      allow_all_providers_to_make_decisions(accredited_course.provider, accredited_course.accredited_provider)
      provider_user.providers << [course.provider, accredited_course.accredited_provider]
      provider_user.provider_permissions.first.update(make_decisions: true)
      expect(service.available_providers).to eq([course.provider])
    end

    it 'returns a self-ratified course' do
      provider_user.providers << course.provider
      provider_user.provider_permissions.first.update(make_decisions: true)
      expect(service.available_providers).to eq([course.provider])
    end

    it 'excludes providers lacking org-level make_decisions for ratified courses' do
      provider_user.providers << [course.provider, accredited_course.accredited_provider]
      provider_user.provider_permissions.second.update(make_decisions: true)
      expect(service.available_providers.count).to eq(0)
    end
  end
end
