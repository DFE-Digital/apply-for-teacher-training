require 'rails_helper'

RSpec.describe 'Block submission from blocked candidates' do
  include Devise::Test::IntegrationHelpers

  let(:application_form) { create(:application_form, :completed, :with_degree, submitted_at: nil, candidate:) }
  let(:choice) { create(:application_choice, :unsubmitted, application_form:) }

  context 'when candidate has submission blocked', time: mid_cycle do
    let(:candidate) { create(:candidate, submission_blocked: true) }

    before { sign_in candidate }

    context 'when accessing the review and submit path' do
      it 'renders interstitial page' do
        get candidate_interface_course_choices_course_review_and_submit_path(application_choice_id: choice.id)
        expect(response).to redirect_to(candidate_interface_course_choices_blocked_submissions_path)
      end
    end

    context 'when tries to submit' do
      it 'renders interstitial page' do
        post candidate_interface_course_choices_submit_course_choice_path(choice.id),
             params: {
               candidate_interface_course_choices_submit_application_form: {
                 submit_answer: true,
               },
             }
        expect(response).to redirect_to(candidate_interface_course_choices_blocked_submissions_path)
      end
    end
  end

  context 'when candidate does not have submission blocked', time: mid_cycle do
    let(:candidate) { create(:candidate, submission_blocked: false) }

    before { sign_in candidate }

    context 'when accessing the review and submit path' do
      it 'renders successfully' do
        get candidate_interface_course_choices_course_review_and_submit_path(application_choice_id: choice.id)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when tries to submit' do
      it 'redirects to your applications' do
        FeatureFlag.activate(:candidate_preferences)

        post candidate_interface_course_choices_submit_course_choice_path(choice.id),
             params: {
               candidate_interface_course_choices_submit_application_form: {
                 submit_answer: true,
               },
             }
        expect(response).to redirect_to(new_candidate_interface_pool_opt_in_path(submit_application: true))
        follow_redirect!
        expect(response.body).to include(t('application_form.submit_application_success.title'))
      end
    end

    context 'when candidate_preferences feature flag is off' do
      context 'when tries to submit' do
        it 'redirects to your applications' do
          FeatureFlag.deactivate(:candidate_preferences)

          post candidate_interface_course_choices_submit_course_choice_path(choice.id),
               params: {
                 candidate_interface_course_choices_submit_application_form: {
                   submit_answer: true,
                 },
               }
          expect(response).to redirect_to(candidate_interface_application_choices_path)
          follow_redirect!
          expect(response.body).to include(t('application_form.submit_application_success.title'))
        end
      end
    end
  end
end
