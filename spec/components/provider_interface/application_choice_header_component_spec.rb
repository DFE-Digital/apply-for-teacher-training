require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationChoiceHeaderComponent do
  describe 'rendered component' do
    let(:reject_by_default_at) { 10.days.from_now }
    let(:provider_can_respond) { true }
    let(:provider_can_set_up_interviews) { true }
    let(:status) { 'awaiting_provider_decision' }
    let(:application_choice) { build_stubbed(:application_choice, status: status, reject_by_default_at: reject_by_default_at) }

    subject(:result) do
      render_inline(
        described_class.new(
          application_choice: application_choice,
          provider_can_respond: provider_can_respond,
          provider_can_set_up_interviews: provider_can_set_up_interviews,
        ),
      )
    end

    context 'when interview permissions feature is not active' do
      before { FeatureFlag.deactivate(:interview_permissions) }

      context 'when the application is awaiting provider decision and the user can make decisions' do
        let(:reject_by_default_at) { 1.day.from_now }

        it 'the Make decision and Set up interview buttons are available and RDB info is presented ' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview or make a decision')
          expect(result.css('.govuk-button').first.text).to eq('Set up interview')
          expect(result.css('.govuk-button').last.text).to eq('Make decision')
          expect(result.css('.govuk-inset-text').text).to include(
            "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_s(:govuk_date_and_time)}).",
          )
        end
      end
    end

    context 'when interview permissions feature is active' do
      let(:reject_by_default_at) { 1.day.from_now }

      before { FeatureFlag.activate(:interview_permissions) }

      context 'when the application is awaiting provider decision and the user can make decisions and set up interviews' do
        it 'the Make decision and Set up interview buttons are available and RDB info is presented ' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview or make a decision')
          expect(result.css('.govuk-button').first.text).to eq('Set up interview')
          expect(result.css('.govuk-button').last.text).to eq('Make decision')
          expect(result.css('.govuk-inset-text').text).to include(
            "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_s(:govuk_date_and_time)}).",
          )
        end
      end

      context 'when the application is awaiting provider decision and the user can only set up interviews' do
        let(:provider_can_respond) { false }

        it 'the Set up interview button is available and RDB info is presented ' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview')
          expect(result.css('.govuk-button').first.text).to eq('Set up interview')
          expect(result.css('.govuk-inset-text').text).to include(
            "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_s(:govuk_date_and_time)}).",
          )
        end
      end

      context 'when the application is awaiting provider decision and the user can only make decisions' do
        let(:provider_can_set_up_interviews) { false }

        it 'the Set up interview button is available and RDB info is presented ' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Make a decision')
          expect(result.css('.govuk-button').first.text).to eq('Make decision')
          expect(result.css('.govuk-inset-text').text).to include(
            "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_s(:govuk_date_and_time)}).",
          )
        end
      end
    end

    context 'when the application is awaiting provider decision and the user cannot make decisions' do
      let(:provider_can_respond) { false }
      let(:provider_can_set_up_interviews) { false }
      let(:status) { 'interviewing' }

      it 'presents content without a heading or button' do
        expect(result.css('.govuk-inset-text').text).to include('There are 10 days to respond.')
      end
    end

    context 'when the application has had an offer' do
      let(:dbd_date) { nil }
      let(:application_choice) { build_stubbed(:application_choice, status: 'offer', decline_by_default_at: dbd_date) }

      context 'if the decline by default has not been set yet' do
        it 'does not render any header' do
          expect(result.css('.govuk-inset-text').count).to eq(0)
        end
      end

      context 'if the decline by default is set' do
        let(:dbd_date) { 3.days.from_now.end_of_day }

        it 'renders the header with decline by default information' do
          expect(result.css('.govuk-inset-text > h2').text).to include('Waiting for candidate’s response')
          expect(result.css('.govuk-inset-text > p').text).to include("Your offer will be automatically declined in 3 days (#{3.days.from_now.end_of_day.to_s(:govuk_date_and_time)}) if the candidate does not respond.")
        end
      end
    end

    context 'when the application is awaiting provider decision, reject by default is tomorrow and user cannot make decisions' do
      let(:provider_can_respond) { false }
      let(:provider_can_set_up_interviews) { false }
      let(:reject_by_default_at) { 1.day.from_now }

      it 'formats the reject by default time in a sentence' do
        expect(result.css('.govuk-inset-text').text).to include(
          "This application will be automatically rejected at #{reject_by_default_at.to_s(:govuk_time)} tomorrow",
        )
      end
    end

    describe '#sub_navigation_items' do
      let(:application_choice) do
        create(:application_choice, reject_by_default_at: reject_by_default_at)
      end

      before do
        allow(application_choice).to receive(:interviews).and_return(interviews)
      end

      context 'when there are no interviews' do
        let(:interviews) { class_double(Interview, kept: []) }

        it 'does not show the interview tab' do
          expect(result.css('.app-tab-navigation li:nth-child(2) a').text).not_to include(
            'Interviews',
          )
        end
      end

      context 'when there are interviews' do
        let(:interviews) { class_double(Interview, kept: [build_stubbed(:interview)]) }

        it 'shows the interview tab' do
          expect(result.css('.app-tab-navigation li:nth-child(2) a').text).to include(
            'Interviews',
          )
        end
      end
    end
  end

  describe '#deferred_offer_wizard_applicable?' do
    it 'is true for a deferred offer belonging to the previous recruitment cycle' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.previous_year)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).deferred_offer_wizard_applicable?).to be true
    end

    it 'is false if the provider cannot respond to the application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.previous_year)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: false).deferred_offer_wizard_applicable?).to be false
    end

    it 'is false when the application status is not deferred' do
      application_choice = instance_double(ApplicationChoice, status: 'withdrawn')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.previous_year)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).deferred_offer_wizard_applicable?).to be false
    end

    it 'is false when the application recruitment cycle is current' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.current_year)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).deferred_offer_wizard_applicable?).to be false
    end
  end

  describe '#deferred_offer_equivalent_course_option_available' do
    it 'is true for a deferred offer with an offered course option' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: true))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_equivalent_course_option_available?).to be true
    end

    it 'is false for a deferred offer without an offered option' do
      course_option = instance_double(CourseOption)
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(course_option).to receive(:in_next_cycle).and_return(false)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_equivalent_course_option_available?).to be false
    end

    it 'is false for a deferred offer without an offered option open on apply' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: false))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_equivalent_course_option_available?).to be false
    end
  end

  describe '#rejection_reason_required' do
    it 'is true for a rejected by default application without a rejection reason' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: nil, structured_rejection_reasons: nil)
      allow(application_choice).to receive(:no_feedback?).and_return(true)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).rejection_reason_required?).to be true
    end

    it 'is false if the provider cannot respond to the application' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: nil, structured_rejection_reasons: nil)
      allow(application_choice).to receive(:no_feedback?).and_return(true)

      expect(described_class.new(application_choice: application_choice).rejection_reason_required?).to be false
    end

    it 'is false for a rejected by default application with a rejection reason' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: 'NO!')
      allow(application_choice).to receive(:no_feedback?).and_return(false)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).rejection_reason_required?).to be false
    end

    it 'is false for a rejected application not rejected by default' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: false, rejection_reason: nil)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).rejection_reason_required?).to be false
    end

    it 'is false for a non-rejected application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')

      expect(described_class.new(application_choice: application_choice, provider_can_respond: true).rejection_reason_required?).to be false
    end
  end

  describe '#decline_by_default_text' do
    it 'returns nil if the application is not in the offer state' do
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision')

      expect(described_class.new(application_choice: application_choice).decline_by_default_text).to be_nil
    end

    describe 'returns the correct text when' do
      it 'the dbd is today' do
        application_choice = build_stubbed(
          :application_choice,
          status: 'offer',
          decline_by_default_at: Time.zone.now.end_of_day,
        )

        expected_text = "at the end of today (#{application_choice.decline_by_default_at.to_s(:govuk_date_and_time)})"
        expect(described_class.new(application_choice: application_choice).decline_by_default_text).to eq(expected_text)
      end

      it 'the dbd is tomorrow' do
        application_choice = build_stubbed(
          :application_choice,
          status: 'offer',
          decline_by_default_at: 1.day.from_now.end_of_day,
        )

        expected_text = "at the end of tomorrow (#{application_choice.decline_by_default_at.to_s(:govuk_date_and_time)})"
        expect(described_class.new(application_choice: application_choice).decline_by_default_text).to eq(expected_text)
      end

      it 'the dbd is after tomorrow' do
        application_choice = build_stubbed(
          :application_choice,
          status: 'offer',
          decline_by_default_at: 3.days.from_now.end_of_day,
        )

        expected_text = "in 3 days (#{application_choice.decline_by_default_at.to_s(:govuk_date_and_time)})"
        expect(described_class.new(application_choice: application_choice).decline_by_default_text).to eq(expected_text)
      end
    end
  end
end
