require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::DeferredOfferComponent do
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

  describe '#deferred_offer_but_cannot_respond?' do
    it 'is true if the provider cannot respond to the application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.previous_year)

      expect(described_class.new(application_choice: application_choice, provider_can_respond: false).deferred_offer_but_cannot_respond?).to be true
    end
  end

  describe '#deferred_offer_in_current_cycle?' do
    it 'is true for a deferred offer without an open offered option' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: false))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred', recruitment_cycle: RecruitmentCycle.current_year)
      allow(course_option).to receive(:in_next_cycle).and_return(false)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_in_current_cycle?).to be true
    end

    it 'is false for a deferred offer with an open offered option' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: false))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred', recruitment_cycle: RecruitmentCycle.current_year)
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_in_current_cycle?).to be false
    end

    it 'is false for a deferred offer from the previous cycle' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: false))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred', recruitment_cycle: RecruitmentCycle.previous_year)
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:current_course_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_in_current_cycle?).to be false
    end
  end
end
