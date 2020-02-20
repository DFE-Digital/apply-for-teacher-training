require 'rails_helper'

RSpec.describe FilterApplicationChoicesForProviders do
  include CourseOptionHelpers

  it 'can filter application choices by status' do
    current_provider = create(:provider)

    page_state = instance_double('ProviderApplicationsPageState', :filter_options => %W(offer rejected))

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'declined',
      application_form: create(:application_form, first_name: 'Aaron'),
    )

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'rejected',
      application_form: create(:application_form, first_name: 'Jim'),
    )
    create(
      :application_choice,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_provider_decision',
      application_form: create(:application_form, first_name: 'Harry'),
    )

    create_list(
      :application_choice,
      4,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'offer',
    )

    create_list(
      :application_choice,
      2,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'rejected',
      application_form: create(:application_form, first_name: 'Alex'),
    )

    application_choices = GetApplicationChoicesForProviders.call(providers: current_provider)

    filtered_application_choices = FilterApplicationChoicesForProviders.call(application_choices: application_choices, page_state: page_state)

    filtered_application_choices_statuses = filtered_application_choices.map { |application_choice| application_choice.status }

    expect(filtered_application_choices_statuses.count('offer')).to be(4)
    expect(filtered_application_choices_statuses.count('rejected')).to be(3)
    expect(filtered_application_choices_statuses).not_to include('awaiting_provider_decision', 'declined')
  end
end

