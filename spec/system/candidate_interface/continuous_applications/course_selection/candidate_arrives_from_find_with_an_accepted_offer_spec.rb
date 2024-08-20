require 'rails_helper'

RSpec.describe 'A candidate with an accepted offer arriving from Find' do
  include CourseOptionHelpers
  include SignInHelper
  include CandidateHelper

  scenario 'candidate is redirected to post offer dashboard' do
    given_i_am_an_existing_candidate_on_apply
    and_i_have_an_accepted_offer
    and_the_course_i_selected_only_has_one_site
    when_i_arrive_at_the_apply_from_find
    then_i_am_on_the_post_offer_dashboard
  end

  def given_i_am_signed_out
    when_i_sign_out
  end

  def and_the_course_i_selected_only_has_one_site
    @course = create(:course, :open, name: 'History')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course)
  end

  def and_i_am_an_existing_candidate_on_apply
    @email = "#{SecureRandom.hex}@example.com"
    @candidate = create(:candidate, email_address: @email)
  end
  alias_method :given_i_am_an_existing_candidate_on_apply, :and_i_am_an_existing_candidate_on_apply

  def and_i_have_an_accepted_offer
    application_form = create(:application_form, candidate: @candidate)
    create(:application_choice, :accepted, application_form:)
  end

  def when_i_arrive_at_the_apply_from_find
    and_i_go_to_sign_in(candidate: @candidate)

    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end
end
