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

      context 'when the Candidate does have a degree' do
        it "sets the 'degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'some grade')

          application_form = build(:application_form, degrees_completed:, degree_qualifications:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('show_all_courses')
        end
      end

      context "when the Candidate has a 'Third-class honours' Degree" do
        it "sets the 'degree_required' parameter to 'third_class'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'Third-class honours')

          application_form = build(:application_form, degrees_completed:, degree_qualifications:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('third_class')
        end
      end

      context "when the Candidate has a 'Lower second-class honours (2:2)' Degree" do
        it "sets the 'degree_required' parameter to 'two_two'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'Lower second-class honours (2:2)')

          application_form = build(:application_form, degrees_completed:, degree_qualifications:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('two_two')
        end
      end

      context "when the Candidate has a 'First-class honours' Degree" do
        it "sets the 'degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'First-class honours')

          application_form = build(:application_form, degrees_completed:, degree_qualifications:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('show_all_courses')
        end
      end

      context "when the Candidate has a 'First-class honours' Degree and a 'Third-class honours' Degree" do
        it "sets the 'degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = [
            build(:degree_qualification, grade: 'Third-class honours'),
            build(:degree_qualification, grade: 'First-class honours'),
          ]

          application_form = build(:application_form, degrees_completed:, degree_qualifications:)
          candidate = build(:candidate, application_forms: [application_form])

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('show_all_courses')
        end
      end
    end

    describe "the 'funding_type' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it "does not set the 'funding_type' parameter" do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters).not_to have_key('funding_type')
        end
      end

      context 'when the Candidate has submitted any Application Choice to a fee funded Course' do
        it "sets the 'funding_type' parameter to 'fee" do
          course = create(:course, funding_type: 'fee')
          course_option = create(:course_option, course:)
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['funding_type']).to eq('fee')
        end
      end

      context 'when the Candidate has submitted several Application Choices' do
        it "sets the 'funding_type' parameter to include all funding types that have been applied to" do
          fee_course_option = create(:course_option, course: build(:course, funding_type: 'fee'))
          salary_course_option = create(:course_option, course: build(:course, funding_type: 'salary'))
          apprenticeship_course_option = create(:course_option, course: build(:course, funding_type: 'apprenticeship'))
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = [
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: fee_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: salary_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: apprenticeship_course_option),
          ]

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['funding_type']).to eq('apprenticeship,fee,salary')
        end
      end
    end

    describe "the 'qualification' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it "does not set the 'qualification' parameter" do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters).not_to have_key('qualification')
        end
      end

      context 'when the Candidate has submitted any Application Choice to a QTS only Course' do
        it "sets the 'qualification' parameter to 'qts" do
          course = create(:course, qualifications: [:qts])
          course_option = create(:course_option, course:)
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['qualification']).to eq('qts')
        end
      end

      context 'when the Candidate has submitted several Application Choices' do
        it "sets the 'qualification' parameter to a combination of all qualification types" do
          qts_only_course_option = create(:course_option, course: build(:course, qualifications: [:qts]))
          undergraduate_and_qts_course_option = create(:course_option, course: build(:course, qualifications: %i[undergraduate qts]))
          pgde_course_option = create(:course_option, course: build(:course, qualifications: [:pgde]))
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = [
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: qts_only_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: undergraduate_and_qts_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: pgde_course_option),
          ]

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['qualification']).to eq('pgde,qts,undergraduate')
        end
      end
    end
  end
end
