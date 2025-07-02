require 'rails_helper'

RSpec.describe 'Support interface - Candidates, Course Recommendations' do
  before do
    allow(SupportUser).to receive(:load_from_session).and_return(create(:support_user))
  end

  it 'redirects to the support root' do
    get support_interface_candidate_course_recommendation_path(create(:candidate))

    expect(response).to redirect_to(support_interface_root_path)
    expect(request.flash[:notice]).to eq('We are unable to recommend a course for this candidate.')
  end
end
