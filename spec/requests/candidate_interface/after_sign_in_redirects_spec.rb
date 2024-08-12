require 'rails_helper'

RSpec.describe 'After sign in redirects' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate, course_from_find:) }
  let(:application_form) { create(:application_form, :completed, candidate:) }
  let(:course_from_find) { create(:course) }

  before do
    sign_in candidate
  end

  context 'when course from find is not present' do
    let(:candidate) { create(:candidate, course_from_find: nil) }

    context 'when application is pre continuous applications' do
      let!(:application_form) { create(:application_form, :completed, :pre_continuous_applications, candidate: candidate) }

      it 'redirects to application complete path' do
        get candidate_interface_interstitial_path
        expect(response).to redirect_to(candidate_interface_continuous_applications_details_path)
      end
    end

    context 'when application is continuous applications' do
      let!(:application_form) { create(:application_form, :minimum_info, :continuous_applications, submitted_at: nil, candidate: candidate) }

      it 'redirects to application details path' do
        get candidate_interface_interstitial_path
        expect(response).to redirect_to(candidate_interface_continuous_applications_details_path)
      end
    end

    context 'when application contains an accepted offer' do
      let!(:application_form) do
        create(:application_form, :minimum_info, :continuous_applications, submitted_at: nil, candidate: candidate)
      end

      it 'redirects to application offer dashboard path' do
        create(:application_choice, :accepted, application_form:)
        get candidate_interface_interstitial_path
        expect(response).to redirect_to(candidate_interface_application_offer_dashboard_path)
      end
    end

    context 'when application contains an accepted offer and access the root page' do
      let!(:application_form) do
        create(:application_form, :minimum_info, :continuous_applications, submitted_at: nil, candidate: candidate)
      end

      it 'redirects to application offer dashboard path' do
        create(:application_choice, :accepted, application_form:)
        get root_path
        follow_redirect!
        expect(response).to redirect_to(candidate_interface_application_offer_dashboard_path)
      end
    end
  end

  context 'when application submitted and non continuous applications' do
    let!(:application_form) { create(:application_form, :completed, :pre_continuous_applications, candidate: candidate) }

    it 'redirects to application complete path' do
      get candidate_interface_interstitial_path
      expect(response).to redirect_to(candidate_interface_application_complete_path)
    end
  end

  context 'when application already contains course from find' do
    it 'redirects to your applications and shows a message to the candidate' do
      create(:application_choice, :awaiting_provider_decision, application_form:, course_option: create(:course_option, course: course_from_find))
      get candidate_interface_interstitial_path
      expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
      follow_redirect!
      expect(response.body).to include("You have already added an application for #{course_from_find.name}")
    end
  end

  context 'when reaching maximum number of choices' do
    it 'redirects to your applications and shows a message to the candidate' do
      create_list(:application_choice, ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES, :continuous_applications, :awaiting_provider_decision, application_form:)
      get candidate_interface_interstitial_path
      expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('errors.messages.too_many_course_choices', max_applications: ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES, course_name: course_from_find.name))
    end
  end

  context 'when reaching maximum unsuccessful number of choices' do
    it 'redirects to your applications and shows a message to the candidate' do
      create_list(:application_choice, ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS, :continuous_applications, :rejected, application_form:)
      get candidate_interface_interstitial_path
      expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('errors.messages.too_many_unsuccessful_choices', max_unsuccessful_applications: ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS))
    end
  end

  context 'when candidate can confirm the course selected' do
    it 'redirects to confirm selection page' do
      get candidate_interface_interstitial_path
      expect(response).to redirect_to(candidate_interface_continuous_applications_course_confirm_selection_path(course_from_find.id))
    end
  end
end
