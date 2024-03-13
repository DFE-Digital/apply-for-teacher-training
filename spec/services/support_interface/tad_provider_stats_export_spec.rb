require 'rails_helper'

RSpec.describe SupportInterface::TADProviderStatsExport, :bullet do
  include CourseOptionHelpers

  describe 'documentation' do
    before do
      provider = create(:provider)
      course_option_for_provider(provider:, course: create(:course, :open_on_apply, provider:))
    end

    it_behaves_like 'a data export'
  end

  subject(:exported_rows) { Bullet.profile { described_class.new.call } }

  describe 'calculating offers and acceptances' do
    states_excluded_from_tad_export = [:offer_deferred]
    accepted_states = ApplicationStateChange.accepted - states_excluded_from_tad_export
    offered_states = ApplicationStateChange.offered - states_excluded_from_tad_export

    unless accepted_states.count < offered_states.count &&
           (offered_states & accepted_states) == accepted_states
      raise 'This spec assumes that ApplicationStateChange.accepted is a subset of ApplicationStateChange.offered'
    end

    test_data = [
      [%i[awaiting_provider_decision], 1, 0, 0],
      [ApplicationStateChange.offered, offered_states.count, offered_states.count, accepted_states.count],
      [ApplicationStateChange.accepted, accepted_states.count, accepted_states.count, accepted_states.count],
      [ApplicationStateChange.not_visible_to_provider, 0, 0, 0],
    ]

    test_data.each do |states, applications, offers, acceptances|
      it "correctly reports overall/offered/accepted tallies for applications in the states #{states}" do
        provider = create(:provider)
        course_option = course_option_for_provider(provider:)

        states.each do |state|
          create(:application_choice, status: state, course_option:)
        end

        expect(exported_rows.first[:applications]).to eq applications
        expect(exported_rows.first[:offers]).to eq offers
        expect(exported_rows.first[:acceptances]).to eq acceptances
      end
    end

    it 'correctly reports course metadata' do
      provider_one = create(:provider, code: 'ABC1', name: 'Tehanu')
      provider_two = create(:provider, code: 'DEF2', name: 'Anarres')

      course_option_for_provider(provider: provider_one, course: create(:course, :open_on_apply, name: 'History', provider: provider_one, code: 'XYZ'))
      course_option_for_provider(provider: provider_one, course: create(:course, :open_on_apply, name: 'Biology', provider: provider_one))
      course_option_for_provider(provider: provider_two, course: create(:course, :open_on_apply, name: 'Science book', provider: provider_two))
      course_option_for_provider(provider: provider_two, course: create(:course, :open_on_apply, name: 'French I took', provider: provider_two))
      course_option_for_provider(provider: provider_two, recruitment_cycle_year: RecruitmentCycle.previous_year)
      course_option_for_provider(provider: provider_two, recruitment_cycle_year: RecruitmentCycle.previous_year)
      # we get a row per course
      expect(exported_rows.count).to eq(4)

      # rows are correctly divided between providers
      expect(exported_rows.map { |r| r[:provider_name] }.tally['Tehanu']).to eq(2)
      expect(exported_rows.map { |r| r[:provider_name] }.tally['Anarres']).to eq(2)

      # rows contain metadata
      example_row = exported_rows.find { |r| r[:subject] == 'History' }
      expect(example_row[:provider_name]).to eq('Tehanu')
      expect(example_row[:provider_code]).to eq('ABC1')
      expect(example_row[:course_code]).to eq('XYZ')
    end
  end
end
