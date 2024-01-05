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
          'This application was received today. You should try and respond to the candidate within 30 days.',
        )
      end

      context 'when the application is awaiting provider decision and the user can only set up interviews' do
        let(:provider_can_respond) { false }

        it 'the Set up interview button is available and RDB info is presented' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview')
          expect(result.css('.govuk-button').first.text).to eq('Set up interview')
          expect(result.css('.govuk-inset-text').text).to include(
            'This application was received today. You should try and respond to the candidate within 30 days.',
          )
        end
      end

      context 'when the application is awaiting provider decision and the user can only make decisions' do
        let(:provider_can_set_up_interviews) { false }

        it 'the Set up interview button is available and RDB info is presented' do
          expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Make a decision')
          expect(result.css('.govuk-button').first.text).to eq('Make decision')
          expect(result.css('.govuk-inset-text').text).to include(
            'This application was received today. You should try and respond to the candidate within 30 days.',
          )
        end
      end
    end

    context 'when the application is inactive and the provider can make decisions' do
      let(:provider_can_respond) { true }
      let(:status) { :inactive }

      it 'renders the make decision button' do
        expect(result.css('h2.govuk-heading-m').first.text.strip).to eq('Set up an interview or make a decision')
        expect(result.css('.govuk-button').first.text).to eq('Set up interview')
        expect(result.css('.govuk-button--secondary').last.text).to eq('Make decision')
      end
    end

    context 'when the application is RBD with no feedback and the user can make decisions' do
      let(:reject_by_default_at) { 1.day.ago }
      let(:status) { :rejected }
      let(:rejected_by_default) { true }
      let(:reject_by_default_days) { 40 }

      it 'render tabs' do
        expect(result.text.split.join(' ')).to eq('Rejected Application Notes Timeline')
      end
    end

    context 'when the application is awaiting provider decision and the user cannot make decisions' do
      let(:provider_can_respond) { false }
      let(:provider_can_set_up_interviews) { false }
      let(:status) { 'interviewing' }

      it 'presents content without a heading or button' do
        expect(result.css('.govuk-inset-text').text).to include('This application was received today. You should try and respond to the candidate within 30 days')
      end
    end

    context 'when the application has had an offer' do
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

    describe '#sub_navigation_items' do
      let(:application_choice) do
        create(:application_choice, reject_by_default_at:)
      end

      before do
        allow(application_choice).to receive(:interviews).and_return(interviews)
      end

      context 'when the application has ended without success' do
        let(:interviews) { class_double(Interview, kept: []) }

        it 'does not render references tab' do
          %i[offer_withdrawn conditions_not_met rejected declined].each do |factory|
            application_choice = create(:application_choice, factory)
            result = render_inline(
              described_class.new(
                application_choice:,
              ),
            )
            expect(result).to have_no_link('References')
          end
        end
      end

      context 'when the application is successful' do
        let(:interviews) { class_double(Interview, kept: []) }

        it 'renders references tab' do
          %i[recruited offer_deferred accepted offered inactive].each do |factory|
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
end
