require 'rails_helper'

RSpec.describe MonthlyStatistics::BySecondarySubject do
  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by secondary subject'" do
      setup_test_data

      expect(statistics).to eq(
        {
          rows: [
            {
              'Subject' => 'Art and design',
              'Recruited' => 1,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Science',
              'Recruited' => 1,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Biology',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Business studies',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Chemistry',
              'Recruited' => 1,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Citizenship',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Classics',
              'Recruited' => 1,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Communication and media studies',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Computing',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Dance',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Design and technology',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Drama',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Economics',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'English',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Geography',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Health and social care',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'History',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Mathematics',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Modern foreign languages',
              'Recruited' => 1,
              'Conditions pending' => 2,
              'Received an offer' => 4,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 3,
              'Total' => 10,
            },
            {
              'Subject' => 'Music',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 1,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Philosophy',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Physical education',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Physics',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Psychology',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Religious education',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 1,
              'Total' => 1,
            },
            {
              'Subject' => 'Social sciences',
              'Recruited' => 0,
              'Conditions pending' => 0,
              'Received an offer' => 1,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
            {
              'Subject' => 'Further education',
              'Recruited' => 0,
              'Conditions pending' => 1,
              'Received an offer' => 0,
              'Awaiting provider decisions' => 0,
              'Unsuccessful' => 0,
              'Total' => 1,
            },
          ],
          column_totals: [5, 9, 12, 1, 9, 36],
        },
      )
    end
  end

  def setup_test_data
    # previous year
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', subject: 'Art and design')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Biology')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Business studies')
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', subject: 'Chemistry')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Citizenship')
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', subject: 'Classics')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Communication and media studies')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'English as a second or other language')
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', subject: 'Italian')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'English as a second or other language')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Further education')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Health and social care')
    create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', subject: 'Philosophy')
    create_application_choice_for_last_cycle(status_before_deferral: 'recruited', subject: 'Science')

    # current year
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Computing')
    create_application_choice_for_this_cycle(status: :with_conditions_not_met, subject: 'Dance')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Design and technology')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'Drama')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Economics')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'English')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Geography')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'History')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Mathematics')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'French')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'German')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'Mandarin')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Spanish')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Japanese')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Russian')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'Modern languages (other)')
    create_application_choice_for_this_cycle(status: :awaiting_provider_decision, subject: 'Music')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Physical education')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'Physics')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Psychology')
    create_application_choice_for_this_cycle(status: :with_rejection, subject: 'Religious education')
    create_application_choice_for_this_cycle(status: :with_offer, subject: 'Social sciences')
  end

  def create_application_choice_for_this_cycle(status:, subject:)
    create(:application_choice, status, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'secondary', subjects: [create(:subject, name: subject)])))
  end

  def create_application_choice_for_last_cycle(status_before_deferral:, subject:)
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: status_before_deferral, current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: create(:course_option, course: create(:course, level: 'secondary', subjects: [create(:subject, name: subject)])))
  end
end
