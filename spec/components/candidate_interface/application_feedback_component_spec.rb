require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackComponent do
  before { FeatureFlag.activate(:feedback_prompts) }

  it 'renders successfully' do
    result = render_inline(
      described_class.new(
        path: '/candidate/application/degrees',
        page_title: 'Add a degreeeeee',
      ),
    )

    expected_base_url = '/candidate/application/application-feedback'
    expected_query_string = '?page_title=Add+a+degreeeeee&path=%2Fcandidate%2Fapplication%2Fdegrees&section=qualifications'

    expected_url = result.css('a').first.attributes['href'].value

    expect(expected_url).to eq expected_base_url + expected_query_string
  end
end
