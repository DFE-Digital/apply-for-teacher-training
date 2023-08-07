require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationReviewComponent do
  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision)
  end
  let(:course) { application_choice.current_course }
  let(:provider) { application_choice.current_provider }
  let(:links) { result.css('a').map(&:text) }

  context 'when application is unsubmitted' do
    let(:application_choice) do
      create(:application_choice, :unsubmitted)
    end

    it 'shows change course link' do
      expect(links).to include("Change course for #{application_choice.current_course.name_and_code}")
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
        expect(links).to include("Change study mode for #{application_choice.current_course.name_and_code}")
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
      expect(result.css('a')).to be_empty
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
        expect(result.css('a')).to be_empty
      end
    end

    context 'when course has multiple sites' do
      before do
        create(:course_option, site: create(:site, provider:), course:)
        create(:course_option, site: create(:site, provider:), course:)
      end

      it 'does not show change links' do
        expect(result.css('a')).to be_empty
      end
    end
  end
end
