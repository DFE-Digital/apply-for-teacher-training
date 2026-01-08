require 'rails_helper'

RSpec.describe 'Support interface - Application Forms, Course Recommendations' do
  include DfESignInHelpers

  before do
    support_user = create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    support_user_exists_dsi(email_address: support_user.email_address)
    get auth_dfe_support_callback_path
  end

  it 'redirects to the support root' do
    get support_interface_application_form_course_recommendation_path(create(:application_form))

    expect(response).to redirect_to(support_interface_root_path)
    expect(request.flash[:notice]).to eq('We are unable to recommend a course for this application form.')
  end

  context 'when a course recommendation is available' do
    it 'redirects to the url from the course recommendation service' do
      url = URI.join(I18n.t('find_teacher_training.production_url'), 'results').to_s
      allow(CandidateCoursesRecommender).to receive(:recommended_courses_url).and_return(url)

      get support_interface_application_form_course_recommendation_path(create(:application_form))

      expect(response).to redirect_to(url)
    end
  end
end
