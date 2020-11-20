require 'rails_helper'

RSpec.describe 'Syncing providers', sidekiq: true do
  include TeacherTrainingAPIHelper

  scenario 'Creates and updates providers' do
    given_there_are_2_providers_in_the_teacher_training_api
    and_one_of_the_providers_exists_already

    when_the_sync_runs
    then_it_creates_one_provider
    and_it_updates_another
    # and_it_sets_the_last_synced_timestamp
  end

  def given_there_are_2_providers_in_the_teacher_training_api
    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'ABC',
          name: 'ABC College',
        },
        {
          code: 'DEF',
          name: 'DER College',
        },
      ],
    )
  end

  def and_one_of_the_providers_exists_already
    create(:provider, code: 'DEF', name: 'DEF College')
  end

  def when_the_sync_runs
    TeacherTrainingAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  def then_it_creates_one_provider
    expect(Provider.find_by(code: 'ABC')).not_to be_nil
  end

  def and_it_updates_another
    expect(Provider.find_by(code: 'DEF').name).to eql('DER College')
  end
  #
  # def and_it_sets_the_last_synced_timestamp
  #   expect(TeacherTrainingAPI::SyncCheck.last_sync).not_to be_blank
  # end

  def stub_teacher_training_api_all_providers(recruitment_cycle_year: RecruitmentCycle.current_year)
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    )
  end

  def stub_teacher_training_api_all_providers_200(provider_details)
    stub_teacher_training_api_all_providers
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: provider_list_response(provider_details),
      )
  end

  def provider_list_response(provider_attributes_to_return = [])
    api_response = JSON.parse(
      File.read(
        Rails.root.join('spec/examples/teacher_training_api/provider_list_response.json'),
      ),
      symbolize_names: true,
    )

    if provider_attributes_to_return
      individual_provider_entry = api_response[:data].first
      new_data = provider_attributes_to_return.map do |attrs|
        individual_provider_entry.deep_merge(attrs)
      end
      api_response[:data] = new_data
    end

    api_response.to_json
  end
end
