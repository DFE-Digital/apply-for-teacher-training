require 'rails_helper'

RSpec.describe GetApplicationChoicesForProviders do
  include CourseOptionHelpers

  it 'raises an exception when the provider is nil' do
    expect {
      GetApplicationChoicesForProviders.call(providers: nil)
    }.to raise_error(MissingProvider)
  end

  it 'returns the application for the given provider' do
    current_provider = create(:provider, code: 'BAT')

    create_list(
      :application_choice,
      2,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_provider_decision',
    )

    alternate_provider = create(:provider, code: 'DIFFERENT')

    create_list(
      :application_choice,
      4,
      course_option: course_option_for_provider(provider: alternate_provider),
      status: 'awaiting_provider_decision',
    )

    returned_applications = GetApplicationChoicesForProviders.call(providers: current_provider)
    expect(returned_applications.size).to be(2)
  end

  it 'returns the application for multiple providers' do
    bat_provider = create(:provider, code: 'BAT')
    man_provider = create(:provider, code: 'MAN')

    bat_choice = create(
      :application_choice,
      course_option: course_option_for_provider(provider: bat_provider),
      status: 'awaiting_provider_decision',
    )

    man_choice = create(
      :application_choice,
      course_option: course_option_for_provider(provider: man_provider),
      status: 'awaiting_provider_decision',
    )

    alternate_provider = create(:provider, code: 'DIFFERENT')

    create_list(
      :application_choice,
      1,
      course_option: course_option_for_provider(provider: alternate_provider),
      status: 'awaiting_provider_decision',
    )

    returned_applications = GetApplicationChoicesForProviders.call(providers: [bat_provider, man_provider])

    expect(returned_applications.map(&:id)).to match_array([bat_choice.id, man_choice.id])
  end

  it 'raises an error if the provider argument is missing' do
    expect {
      GetApplicationChoicesForProviders.call(providers: [])
    }.to raise_error(MissingProvider)

    expect {
      GetApplicationChoicesForProviders.call(providers: [''])
    }.to raise_error(MissingProvider)

    expect {
      GetApplicationChoicesForProviders.call(providers: '')
    }.to raise_error(MissingProvider)

    expect {
      GetApplicationChoicesForProviders.call(providers: nil)
    }.to raise_error(MissingProvider)
  end

  it 'returns applications that are in a state visible to providers' do
    current_provider = create(:provider, code: 'BAT')

    create_list(
      :application_choice,
      3,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_provider_decision',
    )

    create_list(
      :application_choice,
      4,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'unsubmitted',
    )

    create_list(
      :application_choice,
      2,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_references',
    )

    returned_applications = GetApplicationChoicesForProviders.call(providers: current_provider)
    expect(returned_applications.size).to be(3)
  end

  it 'returns application_choice that the provider is the accrediting body for' do
    current_provider = create(:provider, code: 'BAT')
    alternate_provider = create(:provider, code: 'DIFFERENT')

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_provider_decision',
      application_form: create(:application_form, first_name: 'Aaron'),
    )

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_provider_decision',
      application_form: create(:application_form, first_name: 'Jim'),
    )
    create(
      :application_choice,
      course_option: course_option_for_accrediting_provider(provider: alternate_provider, accrediting_provider: current_provider),
      status: 'awaiting_provider_decision',
      application_form: create(:application_form, first_name: 'Harry'),
    )

    create_list(
      :application_choice,
      4,
      course_option: course_option_for_provider(provider: alternate_provider),
      status: 'awaiting_provider_decision',
    )

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: alternate_provider),
      status: 'awaiting_provider_decision',
      application_form: create(:application_form, first_name: 'Alex'),
    )

    returned_applications = GetApplicationChoicesForProviders.call(providers: current_provider)
    returned_application_names = returned_applications.map { |a| a.application_form.first_name }

    expect(returned_application_names).to include('Aaron', 'Jim', 'Harry')
    expect(returned_application_names).not_to include('Alex')
  end
end
