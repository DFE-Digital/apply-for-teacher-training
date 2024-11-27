require 'rails_helper'

RSpec.describe CandidateInterface::CoursesRecommender do
  describe '.recommended_courses_url' do
    it 'returns nil when there is no recommendations' do
      candidate = build(:candidate)

      expect(described_class.recommended_courses_url(candidate:)).to be_nil
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
        it 'does not recommend courses' do
          right_to_work_or_study = 'no'
          personal_details_completed = false

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, right_to_work_or_study:, personal_details_completed:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
        end
      end

      context 'when the Candidate does have the right to work or study in UK' do
        it "sets the can_sponsor_visa parameter to 'false'" do
          right_to_work_or_study = 'yes'
          personal_details_completed = true

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, right_to_work_or_study:, personal_details_completed:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['can_sponsor_visa']).to eq('false')
        end
      end

      context 'when the Candidate does not have the right to work or study in UK' do
        it "sets the 'can_sponsor_visa' parameter to 'true'" do
          right_to_work_or_study = 'no'
          personal_details_completed = true

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, right_to_work_or_study:, personal_details_completed:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['can_sponsor_visa']).to eq('true')
        end
      end
    end

    describe "the 'degree_required' parameter" do
      context 'when the Candidate has not completed their Degree details' do
        it 'does not recommend courses' do
          degrees_completed = false

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
        end
      end

      context 'when the Candidate does not have a degree' do
        it "sets the 'degree_required' parameter to 'not_required'" do
          degrees_completed = true

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('not_required')
        end
      end

      context 'when the Candidate does have a degree' do
        it "sets the 'degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'some grade')

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('show_all_courses')
        end
      end

      context "when the Candidate has a 'Third-class honours' Degree" do
        it "sets the 'degree_required' parameter to 'third_class'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'Third-class honours')

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('third_class')
        end
      end

      context "when the Candidate has a 'Lower second-class honours (2:2)' Degree" do
        it "sets the 'degree_required' parameter to 'two_two'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'Lower second-class honours (2:2)')

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('two_two')
        end
      end

      context "when the Candidate has a 'First-class honours' Degree" do
        it "sets the 'degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'First-class honours')

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

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

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['degree_required']).to eq('show_all_courses')
        end
      end
    end

    describe "the 'funding_type' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
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
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
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

    describe "the 'study_type' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
        end
      end

      context 'when the Candidate has submitted any Application Choice to a Full Time Course' do
        it "sets the 'study_type' parameter to 'full_time" do
          course_option = create(:course_option, study_mode: :full_time)
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['study_type']).to eq('full_time')
        end
      end

      context 'when the Candidate has submitted several Application Choices' do
        it "sets the 'study_type' parameter to a combination of all study modes" do
          full_time_course_option = create(:course_option, study_mode: :full_time)
          part_time_course_option = create(:course_option, study_mode: :part_time)
          other_full_time_course_option = create(:course_option, study_mode: :full_time)
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = [
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: full_time_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: part_time_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: other_full_time_course_option),
          ]

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['study_type']).to eq('full_time,part_time')
        end
      end
    end

    describe "the 'subjects' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
        end
      end

      context "when the Candidate has submitted any Application Choice to an 'A1' Course" do
        it "sets the 'subjects' parameter to 'A1" do
          course = create(:course, subjects: [create(:subject, code: 'A1')])
          course_option = create(:course_option, course: course)

          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['subjects[]']).to eq('A1')
        end
      end

      context 'when the Candidate has submitted several Application Choices' do
        it "sets the 'subjects' parameter to a combination of all Subject codes" do
          a1_subject = create(:subject, code: 'A1')
          b2_subject = create(:subject, code: 'B2')
          c1_subject = create(:subject, code: 'C1')
          a1_course = create(:course, subjects: [a1_subject])
          b2_course = create(:course, subjects: [b2_subject])
          mixed_course = create(:course, subjects: [c1_subject, a1_subject, b2_subject])

          a1_subject_course_option = create(:course_option, course: a1_course)
          b2_subject_course_option = create(:course_option, course: b2_course)
          mixed_subject_course_option = create(:course_option, course: mixed_course)

          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = [
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: a1_subject_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: b2_subject_course_option),
            create(:application_choice, :awaiting_provider_decision, application_form:, course_option: mixed_subject_course_option),
          ]

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['subjects[]']).to eq(%w[A1 B2 C1])
        end
      end
    end

    describe "the 'radius', 'latitude' and 'longitude' parameters" do
      context 'when a Locatable is not specified' do
        it 'does not recommend courses' do
          candidate = create(:candidate)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_nil
        end
      end

      context 'when a Locatable is specified' do
        it 'sets the parameters to the Locatable values' do
          locatable = instance_double(Provider, latitude: 51.5074, longitude: 0.1278, postcode: 'SW1A 1AA')
          candidate = create(:candidate)

          uri = URI(described_class.recommended_courses_url(candidate:, locatable: locatable))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['radius']).to eq('10')
          expect(query_parameters['latitude']).to eq('51.5074')
          expect(query_parameters['longitude']).to eq('0.1278')
        end
      end

      context "when the Locatable doesn't have all the location data" do
        it 'does not set the any of the parameters' do
          locatable = instance_double(Provider, latitude: nil, longitude: 0.1278, postcode: 'SW1A 1AA')
          candidate = create(:candidate)

          recommended_courses_url = described_class.recommended_courses_url(candidate:, locatable: locatable)

          expect(recommended_courses_url).to be_nil
        end
      end
    end

    context 'a mixture of scenarios' do
      it 'sets the parameters to the correct values' do
        right_to_work_or_study = 'no'
        personal_details_completed = false
        course_option = create(:course_option, study_mode: :full_time)

        candidate = create(:candidate)
        application_form = create(:application_form,
                                  application_choices: [],
                                  candidate:,
                                  right_to_work_or_study:,
                                  personal_details_completed:)
        _application_choices = create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)

        uri = URI(described_class.recommended_courses_url(candidate:))
        query_parameters = Rack::Utils.parse_query(uri.query)

        expect(query_parameters['study_type']).to eq('full_time')

        expect(query_parameters).not_to have_key('can_sponsor_visa')
        expect(query_parameters).not_to have_key('degree_required')
        expect(query_parameters).not_to have_key('radius')
        expect(query_parameters).not_to have_key('latitude')
        expect(query_parameters).not_to have_key('longitude')

        expect(query_parameters).to have_key('funding_type') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('qualification') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('subjects[]') # mystery guest from the Course on the Application Choice
      end

      it 'sets the parameters to the correct values with a locatable' do
        right_to_work_or_study = 'no'
        personal_details_completed = false
        locatable = instance_double(Provider, latitude: 51.5074, longitude: 0.1278, postcode: 'SW1A 1AA')
        course_option = create(:course_option, study_mode: :full_time)

        candidate = create(:candidate)
        application_form = create(:application_form,
                                  application_choices: [],
                                  candidate:,
                                  right_to_work_or_study:,
                                  personal_details_completed:)
        _application_choices = create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)

        uri = URI(described_class.recommended_courses_url(candidate:, locatable:))
        query_parameters = Rack::Utils.parse_query(uri.query)

        expect(query_parameters['radius']).to eq('10')
        expect(query_parameters['latitude']).to eq('51.5074')
        expect(query_parameters['longitude']).to eq('0.1278')
        expect(query_parameters['study_type']).to eq('full_time')

        expect(query_parameters).not_to have_key('can_sponsor_visa')
        expect(query_parameters).not_to have_key('degree_required')

        expect(query_parameters).to have_key('funding_type') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('qualification') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('subjects[]') # mystery guest from the Course on the Application Choice
      end
    end
  end
end
