require 'rails_helper'

RSpec.describe ProviderAuthorisationAnalysis do
  let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
  let(:other_users) do
    [
      # training provider admin
      create(:provider_permissions, provider: course.provider, manage_organisations: true),
      # ratifying provider admin
      create(:provider_permissions, provider: ratifying_provider, manage_users: true),
    ].map(&:provider_user)
  end
  let(:ratifying_provider) { provider_user.providers.first }
  let(:course) { create(:course, accredited_provider: ratifying_provider) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
  let(:auth) { ProviderAuthorisation.new(actor: provider_user) }

  let(:analysis) do
    ProviderAuthorisationAnalysis.new(permission: :make_decisions,
                                      auth: auth,
                                      application_choice: application_choice,
                                      course_option_id: application_choice.course_option_id)
  end

  before do
    create(:provider_relationship_permissions,
           :not_set_up_yet,
           training_provider: course.provider,
           ratifying_provider: ratifying_provider)

    auth.can_make_decisions?(application_choice: application_choice, course_option: course_option)
  end

  it '#ratified_course?' do
    expect(analysis.ratified_course?).to be_truthy
  end

  it '#provider_user_associated_with_training_provider?' do
    expect(analysis.provider_user_associated_with_training_provider?).to be_falsy
  end

  it '#provider_relationship_has_been_set_up?' do
    expect(analysis.provider_relationship_has_been_set_up?).to be_falsy
  end

  it '#provider_relationship_allows_access?' do
    expect(analysis.provider_relationship_allows_access?).to be_falsy
  end

  it '#provider_user_has_user_level_access?' do
    expect(analysis.provider_user_has_user_level_access?).to be_truthy
  end

  it '#provider_user_can_manage_users?' do
    expect(analysis.provider_user_can_manage_users?).to be_falsy
  end

  it '#provider_user_can_manage_organisations?' do
    expect(analysis.provider_user_can_manage_organisations?).to be_falsy
  end

  it '#other_provider_users_who_can_manage_users' do
    expected = other_users.second

    expect(analysis.other_provider_users_who_can_manage_users.count).to eq(1)
    expect(analysis.other_provider_users_who_can_manage_users.first.id).to eq(expected.id)
  end

  it '#training_provider_users_who_can_manage_organisations' do
    expected = other_users.first

    expect(analysis.training_provider_users_who_can_manage_organisations.count).to eq(1)
    expect(analysis.training_provider_users_who_can_manage_organisations.first.id).to eq(expected.id)
  end
end
