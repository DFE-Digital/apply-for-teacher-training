require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackComponent do
  before { FeatureFlag.activate(:feedback_prompts) }

  it 'renders successfully' do
    result = render_inline(
      described_class.new(
        section: 'application_references',
        path: 'candidate_interface_references_start_path',
        page_title: 'This is the references start page',
      ),
    )

    expected_base_url = '/candidate/application/application-feedback'
    expected_query_string = '?page_title=This+is+the+references+start+page&path=candidate_interface_references_start_path&section=application_references'

    expected_url = result.css('a').first.attributes['href'].value

    expect(expected_url).to eq expected_base_url + expected_query_string
  end
end
