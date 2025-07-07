require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationReviewComponent do
  shared_examples_for 'course fee row' do
    describe 'course_fee' do
      context 'where course is not fee-based' do
        let(:fee_domestic) { 9250 }
        let(:fee_international) { 23820 }
        let(:funding_type) { %w[salary apprenticeship].sample }

        it 'does not show course fee row' do
          expect(result.text).not_to include 'UK students: £9,250'
          expect(result.text).not_to include 'International students: £23,820'
          expect(result.text).not_to include 'Course fee'
        end
      end

      context 'where domestic and international fees present' do
        let(:fee_domestic) { 9250 }
        let(:fee_international) { 23820 }

        it 'shows both domestic and international fees' do
          expect(result.text).to include 'Course fee'
          expect(result.text).to include 'UK students: £9,250'
          expect(result.text).to include 'International students: £23,820'
        end
      end

      context 'where only domestic fees are present' do
        let(:fee_domestic) { 9250 }
        let(:fee_international) { nil }

        it 'shows only domestic fees' do
          expect(result.text).to include 'Course fee'
          expect(result.text).to include 'UK students: £9,250'
          expect(result.text).not_to include 'International students:'
        end
      end

      context 'where only international fees are present' do
        let(:fee_domestic) { nil }
        let(:fee_international) { 23820 }

        it 'shows only international fees' do
          expect(result.text).to include 'Course fee'
          expect(result.text).not_to include 'UK students:'
          expect(result.text).to include 'International students: £23,820'
        end
      end
    end
  end

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
    render_inline(component)
  end

  let(:component) { described_class.new(application_choice:) }

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision, personal_statement:, sent_to_provider_at: 1.week.ago, course:)
  end
  let(:provider) { create(:provider) }
  let(:course) { create(:course, :with_course_options, course_length:, provider:, fee_domestic:, fee_international:, funding_type:) }
  let(:fee_domestic) { nil }
  let(:fee_international) { nil }
  let(:funding_type) { 'fee' }
  let(:course_length) { 'OneYear' }
  let(:links) { result.css('a').map(&:text) }
  let(:personal_statement) { 'some personal statement' }

  context 'when application is unsubmitted' do
    let(:application_form) { create(:application_form, becoming_a_teacher:) }
    let(:becoming_a_teacher) { 'becoming a teacher' }
    let(:application_choice) do
      create(:application_choice, :unsubmitted, personal_statement:, course:, application_form:)
    end

    it_behaves_like 'course length row'
    it_behaves_like 'course fee row'

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
      expect(result.text).to include("Personal statement  #{becoming_a_teacher}")
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

    it 'does not show what happens next information' do
      expect(result.text).not_to include('What happens next')
    end

    it 'does not show withdraw CTA' do
      expect(result.text).not_to include('withdraw this application')
    end

    it 'does not show provider contact information' do
      expect(result.text).not_to include('Contact training provider')
    end
  end

  context 'when application is submitted (awaiting_provider_decision)' do
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
        expect(result.text).to include('Application submitted25 December 2023 at 12am (midnight) UK time (7 days ago)')
      end
    end

    it 'shows link to course on find' do
      expect(links).to include(application_choice.current_course.name_and_code)
    end

    it 'shows the personal statement' do
      expect(result).to have_content("Personal statement #{personal_statement}")
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

    it 'show what happens next information' do
      expect(result.text).to include('What happens next',
                                     'The provider will review your application and let your know when they have a made a decision. In the meantime, you can:')
    end

    it 'shows withdraw CTA' do
      expect(result.text).to include('withdraw this application')
    end

    it 'shows provider contact information' do
      expect(result.text).to include('Contact training provider')
    end
  end

  context 'when application is interviewing' do
    let(:cancelled_interview) do
      create(:interview, :cancelled, location: 'cancelled location')
    end
    let(:interviews) do
      [
        create(:interview, location: 'interview 1'),
        create(:interview, location: 'interview 2'),
        cancelled_interview,
      ]
    end
    let(:application_choice) do
      create(:application_choice, :interviewing, interviews:, course:)
    end

    it 'shows interview row' do
      expect(result.text).to include('InterviewYou have an interview scheduled')
    end

    it 'shows all interviews' do
      expect(result.text).to include('interview 1', 'interview 2')
    end

    it 'excludes cancelled interviews' do
      expect(result.text).not_to include(cancelled_interview.location)
    end

    it 'show what happens next information' do
      expect(result.text).to include('What happens next',
                                     'Congratulations on being invited for an interview! This is an important stage in successfully getting a place on a teacher training course.')
    end

    it 'shows withdraw CTA' do
      expect(result.text).to include('withdraw this application')
    end

    it 'shows provider contact information' do
      expect(result.text).to include('Contact training provider')
    end
  end

  context 'when application is inactive' do
    let(:application_choice) do
      create(:application_choice, :inactive, course:)
    end

    context 'when application cannot make more choices' do
      before do
        allow(component).to receive(:can_add_more_choices?).and_return(false)
      end

      it 'show what happens next information' do
        expect(result.text).to include('What happens next',
                                       'The provider will review your application and let you know when they have made a decision. In the meantime, you can:')
      end

      it 'does not hint to add more choices' do
        expect(result.text).not_to include('submit another')
      end

      it 'does not show a warning text' do
        expect(result.text).not_to include('You can add an application for a different training provider while you wait for a decision on this application')
      end
    end

    context 'when application can make more choices' do
      it 'shows hint to add more choices' do
        expect(result.text).to include('submit another')
      end

      it 'does not show a warning text' do
        expect(result.text).to have_content(
          'You can add an application for a different training provider while you wait for a decision on this application.',
        )
      end
    end

    it 'shows withdraw CTA' do
      expect(result.text).to include('withdraw this application')
    end

    it 'shows provider contact information' do
      expect(result.text).to include('Contact training provider')
    end
  end

  context 'when application is rejected' do
    let(:application_choice) do
      create(:application_choice, :rejected_reasons, course:)
    end

    it 'shows reasons for rejection row' do
      expect(result.text).to include('Reasons for rejection')
    end

    it 'does not show what happens next information' do
      expect(result.text).not_to include('What happens next')
    end

    it 'does not show withdraw CTA' do
      expect(result.text).not_to include('withdraw this application')
    end

    it 'does not show provider contact information' do
      expect(result.text).not_to include('Contact training provider')
    end
  end
end
