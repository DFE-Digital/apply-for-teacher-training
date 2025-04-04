require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::DeferredOfferComponent do
  describe 'rendered component' do
    context 'when the deferred offer is from the previous cycle and the provider user can respond' do
      it 'renders Confirm deferred offer content' do
        application_choice = build_stubbed(:application_choice, :offer_deferred)
        allow(application_choice).to receive(:recruitment_cycle).and_return(previous_year)
        result = render_inline(described_class.new(application_choice:, provider_can_respond: true))

        expect(result.css('h2').text.strip).to eq('Confirm deferred offer')
        expect(result.css('.govuk-body').text.strip).to eq('You need to confirm your deferred offer.')
        expect(result.css('.govuk-button').text.strip).to eq('Confirm deferred offer')
      end
    end

    context 'when the deferred offer is in the current cycle' do
      it 'explains the deferred offer will need to be confirmed at the start of the next cycle' do
        application_choice = build_stubbed(:application_choice, :offer_deferred)
        allow(application_choice).to receive(:recruitment_cycle).and_return(current_year)
        result = render_inline(described_class.new(application_choice:, provider_can_respond: true))

        expect(result.text.strip).to eq('Your offer will need to be confirmed at the start of the next recruitment cycle.')
      end
    end

    context 'when the provider user cannot respond' do
      it 'explains that the deferred offer needs to be confirmed' do
        application_choice = build_stubbed(:application_choice, :offer_deferred)
        allow(application_choice).to receive(:recruitment_cycle).and_return(previous_year)
        result = render_inline(described_class.new(application_choice:))

        expect(result.text.strip).to eq('The deferred offer needs to be confirmed.')
      end
    end
  end

  describe '#deferred_offer_wizard_applicable?' do
    it 'is true for a deferred offer belonging to the previous recruitment cycle' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(previous_year)

      expect(described_class.new(application_choice:, provider_can_respond: true).deferred_offer_wizard_applicable?).to be true
    end

    it 'is false if the provider cannot respond to the application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(previous_year)

      expect(described_class.new(application_choice:, provider_can_respond: false).deferred_offer_wizard_applicable?).to be false
    end

    it 'is false when the application status is not deferred' do
      application_choice = instance_double(ApplicationChoice, status: 'withdrawn')
      allow(application_choice).to receive(:recruitment_cycle).and_return(previous_year)

      expect(described_class.new(application_choice:, provider_can_respond: true).deferred_offer_wizard_applicable?).to be false
    end

    it 'is false when the application recruitment cycle is current' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(current_year)

      expect(described_class.new(application_choice:, provider_can_respond: true).deferred_offer_wizard_applicable?).to be false
    end
  end

  describe '#deferred_offer_but_cannot_respond?' do
    it 'is true if the provider cannot respond to the application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(previous_year)

      expect(described_class.new(application_choice:, provider_can_respond: false).deferred_offer_but_cannot_respond?).to be true
    end
  end

  describe '#deferred_offer_in_current_cycle?' do
    it 'is true for a deferred offer without an open offered option' do
      course_option = instance_double(CourseOption, course: instance_double(Course))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred', recruitment_cycle: current_year)
      allow(course_option).to receive(:in_next_cycle).and_return(false)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice:).deferred_offer_in_current_cycle?).to be true
    end

    it 'is false for a deferred offer with an open offered option' do
      course_option = instance_double(CourseOption, course: instance_double(Course))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred', recruitment_cycle: current_year)
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice:).deferred_offer_in_current_cycle?).to be false
    end

    it 'is false for a deferred offer from the previous cycle' do
      course_option = instance_double(CourseOption, course: instance_double(Course))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred', recruitment_cycle: previous_year)
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice:).deferred_offer_in_current_cycle?).to be false
    end
  end
end
