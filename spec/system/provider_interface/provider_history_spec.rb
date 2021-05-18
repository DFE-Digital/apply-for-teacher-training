require 'rails_helper'

RSpec.feature 'Provider history', with_audited: true do
  include DfESignInHelpers

  scenario 'Provider user makes and reviews changes' do
    given_i_am_a_support_user

    when_a_course_is_created_and_updated
    and_a_related_record_is_created
    and_i_visit_the_provider_history
    then_i_see_the_changes
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_a_course_is_created_and_updated
    @provider = create(:provider)
    @provider.update!(sync_courses: true)
  end

  def and_a_related_record_is_created
    course = create(:course, provider: @provider)
    create(:course_option, course: course)
  end

  def and_i_visit_the_provider_history
    visit support_interface_provider_history_path(@provider)
  end

  def then_i_see_the_changes
    expect(page).to have_content 'Create Provider'
    expect(page).to have_content 'Update Provider'
    expect(page).to have_content 'Create Course Option'
  end
end
