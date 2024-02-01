require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationReviewComponent do
  shared_examples_for 'course length row' do
    describe 'course_length' do
      context 'course_length is standard' do
        let(:course_length) { '10 months' }

        it 'shows the course length as is' do
          expect(result.text).to include("Course length#{course.course_length}")
        end
      end

      context 'course_length is blank' do
        let(:course_length) { nil }

        it 'shows the course length as blank' do
          expect(result.text).to include('Course length')
        end
      end

      context 'course_length is OneYear' do
        it 'shows the course length as 1 year' do
          expect(result.text).to include('Course length1 year')
        end
      end

      context 'course_length is TwoYear' do
        let(:course_length) { 'TwoYears' }

        it 'shows the course length as 2 years' do
          expect(result.text).to include('Course lengthUp to 2 years')
        end
      end
    end
  end

  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision, personal_statement:, sent_to_provider_at: 1.week.ago, course:)
  end
  let(:course) { create(:course, :with_course_options, course_length:) }
  let(:course_length) { 'OneYear' }
  let(:provider) { application_choice.current_provider }
  let(:links) { result.css('a').map(&:text) }
  let(:personal_statement) { 'some personal statement' }

  context 'when application is unsubmitted' do
    let(:application_form) { create(:application_form, becoming_a_teacher:) }
    let(:becoming_a_teacher) { 'becoming a teacher' }
    let(:application_choice) do
      create(:application_choice, :unsubmitted, personal_statement:, course:, application_form:)
    end

    it_behaves_like 'course length row'

    it 'shows change course link' do
      expect(links).to include("Change course for #{application_choice.current_course.name_and_code}")
    end

    it 'shows link to course on find' do
      expect(links).to include(application_choice.current_course.name_and_code)
    end

    it 'shows the course qualifications' do
      expect(result.text).to include("Qualifications#{course.qualifications_to_s}")
    end

    it 'does not show the interview row' do
      expect(result.text).not_to include('Interview')
    end

    it 'does not show the application number' do
      expect(result.text).not_to include('Application number')
    end

    it 'shows the application forms becoming_a_teacher as the personal statement' do
      expect(result.text).to include("Personal statement#{becoming_a_teacher}")
    end

    context 'when course has multiple study modes' do
      before do
        create(
          :course_option,
          course:,
          study_mode: :part_time,
        )
        create(
          :course_option,
          course:,
          study_mode: :full_time,
        )
      end

      it 'shows change link on study mode' do
        expect(links).to include("Change full time or part time for #{application_choice.current_course.name_and_code}")
      end
    end

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'shows change link on site' do
        expect(links).to include("Change location for #{application_choice.current_course.name_and_code}")
      end
    end
  end

  context 'when application is submitted' do
    it_behaves_like 'course length row'

    it 'shows the application status' do
      expect(result.text).to include('StatusAwaiting decision')
    end

    it 'does not show change links' do
      expect(result.css('govuk-summary-list__actions a')).to be_empty
    end

    it 'shows personal statement' do
      expect(result.text).to include(personal_statement)
    end

    it 'shows the application number' do
      expect(result.text).to include("Application number#{application_choice.id}")
    end

    it 'shows the course qualifications' do
      expect(result.text).to include("Qualifications#{course.qualifications_to_s}")
    end

    it 'shows the duration since submitted' do
      travel_temporarily_to('1 January 2024') do
        expect(result.text).to include('Application submitted25 December 2023 at 12am (midnight) (7 days ago)')
      end
    end

    it 'shows link to course on find' do
      expect(links).to include(application_choice.current_course.name_and_code)
    end

    it 'shows the personal statement' do
      expect(result).to have_content("Personal statement\n#{personal_statement}")
    end

    it 'does not show the interview row' do
      expect(result.text).not_to include('Interview')
    end

    context 'when course has multiple study modes' do
      before do
        create(
          :course_option,
          course:,
          study_mode: :part_time,
        )
        create(
          :course_option,
          course:,
          study_mode: :full_time,
        )
      end

      it 'does not show change links' do
        expect(result.css('govuk-summary-list__actions a')).to be_empty
      end
    end

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'does not show change links' do
        expect(result.css('govuk-summary-list__actions a')).to be_empty
      end
    end
  end

  context 'when application is interviewing' do
    let(:application_choice) do
      create(:application_choice, :interviewing, interviews: [create(:interview)])
    end

    it 'shows interview row' do
      expect(result.text).to include('InterviewYou have an interview scheduled')
    end
  end

  context 'when application is rejected' do
    let(:application_choice) do
      create(:application_choice, :rejected_reasons)
    end

    it 'shows reasons for rejection row' do
      expect(result.text).to include('Reasons for rejection')
    end
  end
end
