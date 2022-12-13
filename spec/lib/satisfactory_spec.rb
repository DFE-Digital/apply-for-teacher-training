require 'rails_helper'

RSpec.describe Satisfactory do
  describe 'an example sequence' do
    it 'creates a candidate with the correct associations' do
      described_class.root
        .add(:candidate, email_address: 'sample@example.com')
        .with(:application_form).which_is(:submitted)
        .with(:application_choice)
        .and(2, :application_choices)
        .each_with(:course_option).which_is(:part_time)
        .and_same(:candidate)
        .with(:application_form, first_name: 'Jane')
        .with(:application_choice).which_is(:rejected)
        .create

      expect(Candidate.count).to eq(1)
      candidate = Candidate.first

      expect(candidate.email_address).to eq('sample@example.com')

      expect(candidate.application_forms.count).to eq(2)
      first_application_form = candidate.application_forms.first
      expect(first_application_form).to be_submitted

      expect(first_application_form.application_choices.count).to eq(3)

      first_application_choice = first_application_form.application_choices.first
      second_application_choice = first_application_form.application_choices.second
      third_application_choice = first_application_form.application_choices.third

      expect(first_application_choice.current_course_option).to be_full_time
      expect(second_application_choice.current_course_option).to be_part_time
      expect(third_application_choice.current_course_option).to be_part_time

      second_application_form = candidate.application_forms.second

      expect(second_application_form.first_name).to eq('Jane')
      expect(second_application_form.application_choices.count).to eq(1)
      expect(second_application_form.application_choices.first).to be_rejected
    end
  end
end
