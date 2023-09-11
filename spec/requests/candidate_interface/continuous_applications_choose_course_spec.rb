require 'rails_helper'

RSpec.describe 'continuous applications redirects' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'when continuous applications', continuous_applications: true do
    context 'when cycle is over' do
      it 'redirects the user when trying to add a course from find' do
        TestSuiteTimeMachine.travel_permanently_to(after_apply_1_deadline + 1.day)
        provider = create(:provider, code: '8N5', name: 'Snape University')
        course = create(:course, :open_on_apply, name: 'Potions', provider:)

        get candidate_interface_continuous_applications_course_confirm_selection_path(course.id)

        expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
      end
    end

    describe 'choose' do
      it 'redirects choose to continuous applications' do
        get candidate_interface_course_choices_choose_path

        expect(response).to redirect_to(candidate_interface_continuous_applications_do_you_know_the_course_path)
      end
    end

    describe 'find' do
      it 'redirects find to continuous applications' do
        get candidate_interface_go_to_find_path

        expect(response).to redirect_to(candidate_interface_continuous_applications_go_to_find_explanation_path)
      end
    end

    describe 'provider' do
      it 'redirects to provider continuous applications' do
        get candidate_interface_course_choices_provider_path
        expect(response).to redirect_to(candidate_interface_continuous_applications_provider_selection_path)
      end
    end

    describe 'course selection' do
      let(:provider) { create(:provider) }

      it 'redirects to provider continuous applications' do
        get candidate_interface_course_choices_course_path(provider.id)

        expect(response).to redirect_to(candidate_interface_continuous_applications_which_course_are_you_applying_to_path(provider.id))
      end
    end
  end

  context 'when not continuous applications', continuous_applications: false do
    describe 'choose' do
      it 'redirects choose to continuous applications' do
        get candidate_interface_course_choices_choose_path

        expect(response).not_to redirect_to(candidate_interface_continuous_applications_do_you_know_the_course_path)
      end
    end

    describe 'find' do
      it 'redirects find to continuous applications' do
        get candidate_interface_go_to_find_path

        expect(response).not_to redirect_to(candidate_interface_continuous_applications_go_to_find_explanation_path)
      end
    end

    describe 'provider' do
      it 'redirects to provider continuous applications' do
        get candidate_interface_course_choices_provider_path

        expect(response).not_to redirect_to(candidate_interface_continuous_applications_provider_selection_path)
      end
    end

    describe 'course selection' do
      let(:provider) { create(:provider) }

      it 'redirects to provider continuous applications' do
        get candidate_interface_course_choices_course_path(provider.id)

        expect(response).not_to redirect_to(candidate_interface_continuous_applications_which_course_are_you_applying_to_path(provider.id))
      end
    end
  end
end
