require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackComponent do
  before { FeatureFlag.activate(:feedback_prompts) }

  it 'renders successfully' do
    result = render_inline(
      described_class.new(
        section: 'application_references',
        path: 'candidate_interface_references_start_path',
        page_title: 'This is the references start page',
        id_in_path: '1',
      ),
    )

    expected_base_url = '/candidate/application/application-feedback'
    expected_issues_query_string = '?id_in_path=1&issues=true&page_title=This+is+the+references+start+page&path=candidate_interface_references_start_path&section=application_references'
    expected_no_issues_query_string = '?id_in_path=1&issues=false&page_title=This+is+the+references+start+page&path=candidate_interface_references_start_path&section=application_references'

    issues_query_string = result.css('.app-feedback__list-item')[1].attributes['action'].value
    issues_form_action = result.css('.app-feedback__list-item')[1].attributes['method'].value

    no_issues_form_url = result.css('.app-feedback__list-item')[2].attributes['action'].value
    no_issues_form_action = result.css('.app-feedback__list-item')[2].attributes['method'].value

    expect(issues_query_string).to eq expected_base_url + expected_issues_query_string
    expect(issues_form_action).to eq 'post'
    expect(no_issues_form_url).to eq expected_base_url + expected_no_issues_query_string
    expect(no_issues_form_action).to eq 'post'
  end
end
