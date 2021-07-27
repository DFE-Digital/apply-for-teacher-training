require 'rails_helper'

RSpec.describe GetApplicationChoicesForProviders do
  include CourseOptionHelpers

  it 'raises an exception when the provider is nil' do
    expect {
      described_class.call(providers: nil)
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

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: create(:provider, code: 'DIFFERENT')),
      status: 'awaiting_provider_decision',
    )

    returned_applications = described_class.call(providers: current_provider)
    expect(returned_applications.size).to eq(2)
  end

  it 'pre-fetches default model includes' do
    current_provider = create(:provider, code: 'BAT')

    create_list(
      :application_choice,
      2,
      course_option: course_option_for_provider(provider: current_provider),
      status: 'awaiting_provider_decision',
    )

    returned_applications = described_class.call(providers: current_provider)

    expect(returned_applications.first.association(:site)).to be_loaded
    expect(returned_applications.first.association(:application_form)).to be_loaded
    expect(returned_applications.first.association(:provider)).to be_loaded
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

    create(
      :application_choice,
      course_option: course_option_for_provider(provider: create(:provider, code: 'DIFFERENT')),
      status: 'awaiting_provider_decision',
    )

    returned_applications = described_class.call(providers: [bat_provider, man_provider])

    expect(returned_applications.map(&:id)).to match_array([bat_choice.id, man_choice.id])
  end

  it 'raises an error if the provider argument is missing' do
    expect {
      described_class.call(providers: [])
    }.to raise_error(MissingProvider)

    expect {
      described_class.call(providers: [''])
    }.to raise_error(MissingProvider)

    expect {
      described_class.call(providers: '')
    }.to raise_error(MissingProvider)

    expect {
      described_class.call(providers: nil)
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
      status: 'offer_deferred',
    )

    returned_applications = described_class.call(providers: current_provider)
    expect(returned_applications.size).to eq(5)
  end

  it 'returns application_choice that the provider is the accredited body for' do
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
      course_option: course_option_for_accredited_provider(provider: alternate_provider, accredited_provider: current_provider),
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

    returned_applications = described_class.call(providers: current_provider)
    returned_application_names = returned_applications.map { |a| a.application_form.first_name }

    expect(returned_application_names).to include('Aaron', 'Jim', 'Harry')
    expect(returned_application_names).not_to include('Alex')
  end

  it 'returns application choices for courses in cycles visible to providers by default' do
    current_provider = create(:provider)
    provider_we_ratify = create(:provider)

    course_option_for_this_cycle = course_option_for_provider(provider: current_provider)
    course_option_for_past_cycle = course_option_for_provider(provider: current_provider, recruitment_cycle_year: 2016)

    ratified_course_option_for_past_cycle = course_option_for_accredited_provider(
      provider: provider_we_ratify,
      accredited_provider: current_provider,
      recruitment_cycle_year: 2016,
    )

    choice_for_this_cycle = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_for_this_cycle,
    )

    choice_for_past_cycle = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_for_past_cycle,
    )

    ratified_choice_for_past_cycle = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: ratified_course_option_for_past_cycle,
    )

    returned_applications = described_class.call(providers: current_provider)

    expect(returned_applications.map(&:id)).to include(choice_for_this_cycle.id)
    expect(returned_applications.map(&:id)).not_to include(choice_for_past_cycle.id)
    expect(returned_applications.map(&:id)).not_to include(ratified_choice_for_past_cycle.id)
  end

  it 'returns application choices for courses in a specified cycle' do
    current_provider = create(:provider)
    provider_we_ratify = create(:provider)

    course_option_for_current_cycle = course_option_for_provider(provider: current_provider)
    course_option_for_previous_cycle = course_option_for_provider(
      provider: current_provider,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    ratified_course_option_for_previous_cycle = course_option_for_accredited_provider(
      provider: provider_we_ratify,
      accredited_provider: current_provider,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )

    choice_for_current_cycle = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_for_current_cycle,
    )

    choice_for_previous_cycle = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_for_previous_cycle,
    )

    ratified_choice_for_previous_cycle = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: ratified_course_option_for_previous_cycle,
    )

    returned_applications = described_class.call(providers: current_provider, recruitment_cycle_year: RecruitmentCycle.current_year)

    expect(returned_applications.map(&:id)).to include(choice_for_current_cycle.id)
    expect(returned_applications.map(&:id)).not_to include(choice_for_previous_cycle.id)
    expect(returned_applications.map(&:id)).not_to include(ratified_choice_for_previous_cycle.id)
  end

  context 'when vendor_api argument is true' do
    it 'returns applications that are in a state visible to providers in vendor api' do
      current_provider = create(:provider, code: 'BAT')

      create_list(
        :application_choice,
        1,
        course_option: course_option_for_provider(provider: current_provider),
        status: 'awaiting_provider_decision',
      )
      create_list(
        :application_choice,
        2,
        course_option: course_option_for_provider(provider: current_provider),
        status: 'offer_deferred',
      )

      returned_applications = described_class.call(providers: current_provider, vendor_api: true)
      expect(returned_applications.size).to eq(1)
    end
  end

  context 'when query includes argument is provided' do
    it 'only joins to the includes specified' do
      current_provider = create(:provider, code: 'BAT')

      create_list(
        :application_choice,
        1,
        course_option: course_option_for_provider(provider: current_provider),
        status: 'awaiting_provider_decision',
      )

      returned_applications = described_class.call(providers: current_provider, includes: [course_option: :course])

      expect(returned_applications.first.association(:site)).not_to be_loaded
      expect(returned_applications.first.association(:application_form)).not_to be_loaded
      expect(returned_applications.first.association(:provider)).not_to be_loaded
    end
  end
end
