require 'rails_helper'

RSpec.describe CandidateCoursesRecommender do
  describe '.recommended_courses_url' do
    before do
      stubbed_html_with_one_course
    end

    it 'returns falsey when there is no recommendations' do
      candidate = create(:candidate)

      expect(described_class.recommended_courses_url(candidate:)).to be_falsey
    end

    it 'returns falsey when the candidate has safeguarding concerns' do
      candidate = create(:candidate)
      _application_form = create(:application_form, candidate:, right_to_work_or_study: 'yes', personal_details_completed: true)

      allow(candidate).to receive(:safeguarding_concerns?).and_return(true)

      expect(described_class.recommended_courses_url(candidate:)).to be_falsey
    end

    describe "the 'can_sponsor_visa' parameter" do
      context 'when the Candidate has not completed their Personal Details' do
        it 'does not recommend courses' do
          right_to_work_or_study = 'no'
          personal_details_completed = false

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, right_to_work_or_study:, personal_details_completed:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
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

    describe "the 'minimum_degree_required' parameter" do
      context 'when the Candidate has not completed their Degree details' do
        it 'does not recommend courses' do
          degrees_completed = false

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
        end
      end

      context 'when the Candidate does not have a degree' do
        it "sets the 'degree_required' parameter to 'no_degree_required'" do
          degrees_completed = true

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['minimum_degree_required']).to eq('no_degree_required')
        end
      end

      context 'when the Candidate does have a degree' do
        it "sets the 'minimum_degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'some grade')

          candidate = create(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['minimum_degree_required']).to eq('show_all_courses')
        end
      end

      context "when the Candidate has a 'Third-class honours' Degree" do
        it "sets the 'minimum_degree_required' parameter to 'third_class'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'Third-class honours')

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['minimum_degree_required']).to eq('third_class')
        end
      end

      context "when the Candidate has a 'Lower second-class honours (2:2)' Degree" do
        it "sets the 'minimum_degree_required' parameter to 'two_two'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'Lower second-class honours (2:2)')

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['minimum_degree_required']).to eq('two_two')
        end
      end

      context "when the Candidate has a 'First-class honours' Degree" do
        it "sets the 'minimum_degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = build_list(:degree_qualification, 1, grade: 'First-class honours')

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['minimum_degree_required']).to eq('show_all_courses')
        end
      end

      context "when the Candidate has a 'First-class honours' Degree and a 'Third-class honours' Degree" do
        it "sets the 'minimum_degree_required' parameter to 'show_all_courses'" do
          degrees_completed = true
          degree_qualifications = [
            build(:degree_qualification, grade: 'Third-class honours'),
            build(:degree_qualification, grade: 'First-class honours'),
          ]

          candidate = build(:candidate)
          _application_form = create(:application_form, candidate:, degrees_completed:, degree_qualifications:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['minimum_degree_required']).to eq('show_all_courses')
        end
      end
    end

    describe "the 'funding[]' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
        end
      end

      context 'when the Candidate has submitted any Application Choice to a fee funded Course' do
        it "sets the 'funding[]' parameter to 'fee" do
          course = create(:course, funding_type: 'fee')
          course_option = create(:course_option, course:)
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['funding[]']).to eq('fee')
        end
      end

      context 'when the Candidate has submitted several Application Choices' do
        it "sets the 'funding[]' parameter to an array of all funding types that have been applied to" do
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

          expect(query_parameters['funding[]']).to contain_exactly('apprenticeship', 'fee', 'salary')
        end
      end
    end

    describe "the 'study_types[]' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
        end
      end

      context 'when the Candidate has submitted any Application Choice to a Full Time Course' do
        it "sets the 'study_types[]' parameter to 'full_time" do
          course_option = create(:course_option, study_mode: :full_time)
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['study_types[]']).to eq('full_time')
        end
      end

      context 'when the Candidate has submitted several Application Choices' do
        it "sets the 'study_types[]' parameter to an array of all study modes" do
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

          expect(query_parameters['study_types[]']).to contain_exactly('full_time', 'part_time')
        end
      end
    end

    describe "the 'subjects[]' parameter" do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
        end
      end

      context "when the Candidate has submitted any Application Choice to an 'A1' Course" do
        it "sets the 'subjects[]' parameter to 'A1" do
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
        it "sets the 'subjects[]' parameter to an array of all Subject codes" do
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

          expect(query_parameters['subjects[]']).to contain_exactly('A1', 'B2', 'C1')
        end
      end
    end

    describe "the 'location' parameter" do
      context 'when a Locatable is not specified' do
        it 'does not recommend courses' do
          candidate = create(:candidate)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
        end
      end

      context 'when a Locatable is specified' do
        it 'sets the parameters to the Locatable values' do
          locatable = instance_double(Provider, postcode: 'SW1A 1AA')
          candidate = create(:candidate)

          uri = URI(described_class.recommended_courses_url(candidate:, locatable: locatable))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['location']).to eq('SW1A 1AA')
        end
      end
    end

    describe 'the excluded_courses[] parameter' do
      context 'when the Candidate has not submitted any Application Choices' do
        it 'does not recommend courses' do
          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate)
          _application_choices = create_list(:application_choice, 1, :unsubmitted, application_form:)

          recommended_courses_url = described_class.recommended_courses_url(candidate:)

          expect(recommended_courses_url).to be_falsey
        end
      end

      context 'when the Candidate has submitted any Application Choice to Course C12' do
        it "sets the 'excluded_courses[]' parameter to include 'C12'" do
          course = create(:course, code: 'C12', provider: create(:provider, code: 'ABC'))
          course_option = create(:course_option, course: course)

          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choices = create_list(:application_choice, 1, :awaiting_provider_decision, application_form:, course_option:)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['excluded_courses[0][course_code]']).to eq('C12')
          expect(query_parameters['excluded_courses[0][provider_code]']).to eq('ABC')
        end
      end

      context 'when the Candidate has submitted more than one Application Choice to many courses' do
        it "sets the 'excluded_courses[]' parameter to include all course codes" do
          course_1 = create(:course, code: 'C12', provider: create(:provider, code: 'ABC'))
          course_option_1 = create(:course_option, course: course_1)

          course_2 = create(:course, code: 'X98', provider: create(:provider, code: 'XYZ'))
          course_option_2 = create(:course_option, course: course_2)

          candidate = create(:candidate)
          application_form = create(:application_form, candidate: candidate, application_choices: [])
          _application_choice_1 = create(:application_choice, :awaiting_provider_decision, application_form:, course_option: course_option_1)
          _application_choice_2 = create(:application_choice, :awaiting_provider_decision, application_form:, course_option: course_option_2)

          uri = URI(described_class.recommended_courses_url(candidate:))
          query_parameters = Rack::Utils.parse_query(uri.query)

          expect(query_parameters['excluded_courses[0][course_code]']).to eq('C12')
          expect(query_parameters['excluded_courses[0][provider_code]']).to eq('ABC')

          expect(query_parameters['excluded_courses[1][course_code]']).to eq('X98')
          expect(query_parameters['excluded_courses[1][provider_code]']).to eq('XYZ')
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

        expect(query_parameters).not_to have_key('can_sponsor_visa')
        expect(query_parameters).not_to have_key('minimum_degree_required')
        expect(query_parameters).to have_key('funding[]') # mystery guest from the Course on the Application Choice
        expect(query_parameters['study_types[]']).to eq('full_time')
        expect(query_parameters).to have_key('excluded_courses[0][provider_code]') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('excluded_courses[0][course_code]') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('subjects[]') # mystery guest from the Course on the Application Choice
        expect(query_parameters).not_to have_key('location')
      end

      it 'sets the parameters to the correct values with a locatable' do
        right_to_work_or_study = 'no'
        personal_details_completed = false
        locatable = instance_double(Provider,  postcode: 'SW1A 1AA')
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

        expect(query_parameters).not_to have_key('can_sponsor_visa')
        expect(query_parameters).not_to have_key('minimum_degree_required')
        expect(query_parameters).to have_key('funding[]') # mystery guest from the Course on the Application Choice
        expect(query_parameters['study_types[]']).to eq('full_time')
        expect(query_parameters).to have_key('subjects[]') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('excluded_courses[0][provider_code]') # mystery guest from the Course on the Application Choice
        expect(query_parameters).to have_key('excluded_courses[0][course_code]') # mystery guest from the Course on the Application Choice
        expect(query_parameters['location']).to eq('SW1A 1AA')
      end
    end

    context 'number of courses found on the Find service' do
      it 'returns falsey when there are no courses found' do
        stubbed_html_with_no_courses

        candidate = create(:candidate)
        _application_form = create(:application_form, candidate:, degrees_completed: true)

        recommended_courses_url = described_class.new(
          candidate:,
        ).recommended_courses_url

        expect(recommended_courses_url).to be_falsey
      end

      it 'returns a URL when the there is one course found' do
        stubbed_html_with_one_course

        candidate = create(:candidate)
        _application_form = create(:application_form, candidate:, degrees_completed: true)

        recommended_courses_url = described_class.new(
          candidate:,
        ).recommended_courses_url

        expect(recommended_courses_url).not_to be_falsey
      end

      it 'returns a URL when there are multiple courses found' do
        stubbed_html_with_courses

        candidate = create(:candidate)
        _application_form = create(:application_form, candidate:, degrees_completed: true)

        recommended_courses_url = described_class.new(
          candidate:,
        ).recommended_courses_url

        expect(recommended_courses_url).not_to be_falsey
      end
    end
  end

private

  def stubbed_html_with_no_courses
    stubbed_request_with_body('No courses found')
  end

  def stubbed_html_with_one_course
    stubbed_request_with_body('1 course found')
  end

  def stubbed_html_with_courses
    stubbed_request_with_body('7,536 courses found')
  end

  def stubbed_request_with_body(course_count_text)
    uri = URI.join(I18n.t('find_teacher_training.production_url'), 'results')

    body = body_for_stub_with_text(course_count_text)

    stub_request(:get, uri)
      .with(query: hash_including({}))
      .to_return(body: body)
  end

  def body_for_stub_with_text(course_count_text)
    <<-HTML
         <html>
        <body>
          <h1 class="govuk-heading-xl">
              #{course_count_text}
          </h1>
        </body>
        </html>
    HTML
  end
end
