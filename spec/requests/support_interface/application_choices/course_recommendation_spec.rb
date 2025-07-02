require 'rails_helper'

RSpec.describe 'Support interface - Application Choice, Course Recommendations' do
  before do
    allow(SupportUser).to receive(:load_from_session).and_return(create(:support_user))
  end

  it 'redirects to the support root' do
    get support_interface_application_choice_course_recommendation_path(create(:application_choice))

    expect(response).to redirect_to(support_interface_root_path)
    expect(request.flash[:notice]).to eq('We are unable to recommend a course for this application choice.')
  end

  context 'when a course recommendation is available' do
    it 'redirects to the url from the course recommendation service' do
      url = URI.join(I18n.t('find_teacher_training.production_url'), 'results').to_s
      allow(CandidateCoursesRecommender).to receive(:recommended_courses_url).and_return(url)

      get support_interface_application_choice_course_recommendation_path(create(:application_choice))

      expect(response).to redirect_to(url)
    end
  end
end
