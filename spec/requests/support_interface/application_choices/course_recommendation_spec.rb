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
end
