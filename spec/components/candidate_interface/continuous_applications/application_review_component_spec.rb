require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationReviewComponent do
  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision, personal_statement:, sent_to_provider_at: 1.week.ago)
  end
  let(:course) { application_choice.current_course }
  let(:provider) { application_choice.current_provider }
  let(:links) { result.css('a').map(&:text) }
  let(:personal_statement) { 'some personal statement' }

  context 'when application is unsubmitted' do
    let(:application_choice) do
      create(:application_choice, :unsubmitted, personal_statement:)
    end

    it 'shows change course link' do
      expect(links).to include("Change course for #{application_choice.current_course.name_and_code}")
    end

    it 'shows link to course on find' do
      expect(links).to include(application_choice.current_course.name_and_code)
    end

    it 'does not show the application number' do
      expect(links).not_to include("Application number #{application_choice.id}")
    end

    it 'does not show the personal statement' do
      expect(result.text).not_to include(personal_statement)
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
    it 'does not show change links' do
      expect(result.css('govuk-summary-list__actions a')).to be_empty
    end

    it 'shows personal statement' do
      expect(result.text).to include(personal_statement)
    end

    it 'shows the application number' do
      expect(result.text).to include("Application number#{application_choice.id}")
    end

    it 'shows the duration since submitted' do
      travel_temporarily_to('1 January 2024') do
        expect(result.text).to include('Application submitted25 December 2023 at 12am (midnight) (7 days ago)')
      end
    end

    it 'shows link to course on find' do
      expect(links).to include(application_choice.current_course.name_and_code)
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
end
