require 'rails_helper'

RSpec.describe CandidateInterface::CoursesRecommender do
  describe '.recommended_courses_url' do
    it 'does not return a URL be default' do
      candidate = build(:candidate)

      results_url = "#{Rails.application.routes.url_helpers.find_url}results"
      expect(described_class.recommended_courses_url(candidate:)).to eq results_url
    end

    #   expect(query_parameters).to eq({
    #     'can_sponsor_visa' => 'true',
    #     'degree_required' => 'show_all_courses', # show_all_courses two_two third_class not_required
    #     'funding_type' => 'salary,apprenticeship,fee',
    #     'latitude' => '', # for location
    #     'longitude' => '', # for location
    #     'qualification[]' => %w[
    #       pgde
    #       pgce
    #       pgce_with_qts
    #       pgde_with_qts
    #       qts
    #     ],
    #     'radius' => '20', # for location
    #     'study_type[]' => %w[
    #       full_time
    #       part_time
    #     ],
    #     'subjects[]' => %w[
    #       00
    #       01
    #     ], # subject codes
    #   })

    describe "the 'can_sponsor_visa' parameter" do
      context 'when the Candidate has not completed their Personal Details' do
        it "does not set the 'can_sponsor_visa' parameter" do
          right_to_work_or_study = 'no'
          personal_details_completed = false

          application_form = build(:application_form, right_to_work_or_study:, personal_details_completed:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters).not_to have_key('can_sponsor_visa')
        end
      end

      context 'when the Candidate does have the right to work or study in UK' do
        it "sets the can_sponsor_visa parameter to 'false'" do
          right_to_work_or_study = 'yes'
          personal_details_completed = true

          application_form = build(:application_form, right_to_work_or_study:, personal_details_completed:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['can_sponsor_visa']).to eq('false')
        end
      end

      context 'when the Candidate does not have the right to work or study in UK' do
        it "sets the 'can_sponsor_visa' parameter to 'true'" do
          right_to_work_or_study = 'no'
          personal_details_completed = true

          application_form = build(:application_form, right_to_work_or_study:, personal_details_completed:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['can_sponsor_visa']).to eq('true')
        end
      end
    end

    describe "the 'degree_required' parameter" do
      context 'when the Candidate has not completed their Degree details' do
        it "does not set the 'degree_required' parameter" do
          degrees_completed = false

          application_form = build(:application_form, degrees_completed:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters).not_to have_key('degree_required')
        end
      end

      context 'when the Candidate does not have a degree' do
        it "sets the 'degree_required' parameter to 'not_required'" do
          degrees_completed = true

          application_form = build(:application_form, degrees_completed:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('not_required')
        end
      end
    end
  end
end
