require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationChoiceHeaderComponent do
  describe '#deferred_offer_wizard_applicable' do
    it 'is true for a deferred offer belonging to the previous recruitment cycle' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.previous_year)

      expect(described_class.new(application_choice: application_choice).deferred_offer_wizard_applicable).to be true
    end

    it 'is false when the application status is not deferred' do
      application_choice = instance_double(ApplicationChoice, status: 'withdrawn')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.previous_year)

      expect(described_class.new(application_choice: application_choice).deferred_offer_wizard_applicable).to be false
    end

    it 'is false when the application recruitment cycle is current' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(application_choice).to receive(:recruitment_cycle).and_return(RecruitmentCycle.current_year)

      expect(described_class.new(application_choice: application_choice).deferred_offer_wizard_applicable).to be false
    end
  end

  describe '#deferred_offer_equivalent_course_option_available' do
    it 'is true for a deferred offer with an offered course option' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: true))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:offered_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_equivalent_course_option_available).to be true
    end

    it 'is false for a deferred offer without an offered option' do
      course_option = instance_double(CourseOption)
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(course_option).to receive(:in_next_cycle).and_return(false)
      allow(application_choice).to receive(:offered_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_equivalent_course_option_available).to be false
    end

    it 'is false for a deferred offer without an offered option open on apply' do
      course_option = instance_double(CourseOption, course: instance_double(Course, open_on_apply: false))
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')
      allow(course_option).to receive(:in_next_cycle).and_return(course_option)
      allow(application_choice).to receive(:offered_option).and_return(course_option)

      expect(described_class.new(application_choice: application_choice).deferred_offer_equivalent_course_option_available).to be false
    end
  end

  describe '#rejection_reason_required' do
    it 'is true for a rejected by default application without a rejection reason' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: nil)

      expect(described_class.new(application_choice: application_choice).rejection_reason_required).to be true
    end

    it 'is false for a rejected by default application with a rejection reason' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: true, rejection_reason: 'NO!')

      expect(described_class.new(application_choice: application_choice).rejection_reason_required).to be false
    end

    it 'is false for a rejected application not rejected by default' do
      application_choice = instance_double(ApplicationChoice, status: 'rejected', rejected_by_default: false, rejection_reason: nil)

      expect(described_class.new(application_choice: application_choice).rejection_reason_required).to be false
    end

    it 'is false for a non-rejected application' do
      application_choice = instance_double(ApplicationChoice, status: 'offer_deferred')

      expect(described_class.new(application_choice: application_choice).rejection_reason_required).to be false
    end
  end
end
