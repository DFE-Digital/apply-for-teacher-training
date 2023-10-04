require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationChoiceHeaderComponent do
  include Rails.application.routes.url_helpers

  describe 'rendered component' do
    let(:reject_by_default_at) { 10.days.from_now }
    let(:provider_can_respond) { true }
    let(:provider_can_set_up_interviews) { true }
    let(:status) { 'awaiting_provider_decision' }
    let(:rejected_by_default) { false }
    let(:reject_by_default_days) { nil }
    let(:application_choice) do
      build_stubbed(
        :application_choice,
        status:,
        rejected_by_default:,
        reject_by_default_at:,
        reject_by_default_days:,
      )
    end

    subject(:result) do
      render_inline(
        described_class.new(
          application_choice:,
          provider_can_respond:,
          provider_can_set_up_interviews:,
        ),
      )
    end

    context 'when the application is awaiting provider decision and the user can make decisions and set up interviews' do
      let(:reject_by_default_at) { 1.day.from_now }

      it 'the Make decision and Set up interview buttons are available and RDB info is presented' do
        expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview or make a decision')
        expect(result.css('.govuk-button').first.text).to eq('Set up interview')
        expect(result.css('.govuk-button--secondary').last.text).to eq('Make decision')
        expect(result.css('.govuk-inset-text').text).to include(
          "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_fs(:govuk_date_and_time)}).",
        )
      end

      context 'when the application is awaiting provider decision and the user can only set up interviews' do
        let(:provider_can_respond) { false }

        it 'the Set up interview button is available and RDB info is presented' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview')
          expect(result.css('.govuk-button').first.text).to eq('Set up interview')
          expect(result.css('.govuk-inset-text').text).to include(
            "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_fs(:govuk_date_and_time)}).",
          )
        end
      end

      context 'when the application is awaiting provider decision and the user can only make decisions' do
        let(:provider_can_set_up_interviews) { false }

        it 'the Set up interview button is available and RDB info is presented' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Make a decision')
          expect(result.css('.govuk-button').first.text).to eq('Make decision')
          expect(result.css('.govuk-inset-text').text).to include(
            "This application will be automatically rejected if a decision has not been made by the end of tomorrow (#{reject_by_default_at.to_fs(:govuk_date_and_time)}).",
          )
        end
      end
    end

    context 'when the application is RBD with no feedback and the user can make decisions' do
      let(:reject_by_default_at) { 1.day.ago }
      let(:status) { :rejected }
      let(:rejected_by_default) { true }
      let(:reject_by_default_days) { 40 }

      it 'Give feedback button is presented' do
        expect(result.css('.govuk-button').first.text).to eq('Give feedback')
        expect(result.css('.govuk-button').first[:href]).to eq(new_provider_interface_rejection_path(application_choice))
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

    context 'when the application has had an offer and it is not continuous applications', continuous_applications: false do
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
          expect(result.css('.govuk-inset-text > p').text).to include("Your offer will be automatically declined in 3 days (#{3.days.from_now.end_of_day.to_fs(:govuk_date_and_time)}) if the candidate does not respond.")
        end
      end
    end

    context 'when the application has had an offer and it is continuous applications', :continuous_applications do
      let(:application_choice) { create(:application_choice, :offered) }

      context 'when the offer was made today' do
        it 'renders the correct text' do
          expect(result.css('.govuk-inset-text > h2').text).to include('Waiting for candidate’s response')
          expect(result.css('.govuk-inset-text > p').text).to include('You made this offer today. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.')
        end
      end

      context 'when the offer was made before today' do
        before do
          application_choice.update(offered_at: 3.days.ago)
        end

        it 'renders the correct text' do
          expect(result.css('.govuk-inset-text > h2').text).to include('Waiting for candidate’s response')
          expect(result.css('.govuk-inset-text > p').text).to include('You made this offer 3 days ago. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.')
        end
      end
    end

    context 'when the application is awaiting provider decision, reject by default is tomorrow and user cannot make decisions' do
      let(:provider_can_respond) { false }
      let(:provider_can_set_up_interviews) { false }
      let(:reject_by_default_at) { 1.day.from_now }

      it 'formats the reject by default time in a sentence' do
        expect(result.css('.govuk-inset-text').text).to include(
          "This application will be automatically rejected at #{reject_by_default_at.to_fs(:govuk_time)} tomorrow",
        )
      end
    end

    describe '#sub_navigation_items' do
      let(:application_choice) do
        create(:application_choice, reject_by_default_at:)
      end

      before do
        allow(application_choice).to receive(:interviews).and_return(interviews)
      end

      context 'when application is ended without success' do
        let(:interviews) { class_double(Interview, kept: []) }

        it 'does not render references tab' do
          %i[offer_withdrawn conditions_not_met rejected declined].each do |factory|
            application_choice = create(:application_choice, factory)
            result = render_inline(
              described_class.new(
                application_choice:,
              ),
            )
            expect(result).not_to have_link('References')
          end
        end
      end

      context 'when application is success' do
        let(:interviews) { class_double(Interview, kept: []) }

        it 'renders references tab' do
          %i[recruited offer_deferred accepted offered].each do |factory|
            application_choice = create(:application_choice, factory)
            result = render_inline(
              described_class.new(
                application_choice:,
              ),
            )
            expect(result).to have_link('References')
          end
        end
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
          expect(result.css('.app-tab-navigation li a').text).to include(
            'Interviews',
          )
        end
      end
    end
  end

  describe '#rejection_reason_required' do
    it 'is true for a rejected by default application without a rejection reason' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: nil, structured_rejection_reasons: nil)
      allow(application_choice).to receive(:no_feedback?).and_return(true)

      expect(described_class.new(application_choice:, provider_can_respond: true).rejection_reason_required?).to be true
    end

    it 'is false for a rejected by default application with a rejection reason' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: 'NO!')
      allow(application_choice).to receive(:no_feedback?).and_return(false)

      expect(described_class.new(application_choice:, provider_can_respond: true).rejection_reason_required?).to be false
    end

    it 'is false for a rejected application not rejected by default' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: false, rejection_reason: nil)

      expect(described_class.new(application_choice:, provider_can_respond: true).rejection_reason_required?).to be false
    end

    it 'is false for a non-rejected application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')

      expect(described_class.new(application_choice:, provider_can_respond: true).rejection_reason_required?).to be false
    end
  end
end
