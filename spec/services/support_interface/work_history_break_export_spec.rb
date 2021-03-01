require 'rails_helper'

RSpec.describe SupportInterface::WorkHistoryBreakExport do
  describe '#data_for_export' do
    it 'returns an array of hashes for candidates with unexplained breaks in their work history' do
      create(:candidate)
      candidate_one = create(:candidate)
      application_form_one = create(:completed_application_form,
                                    candidate: candidate_one,
                                    date_of_birth: Date.new(1982, 1, 15),
                                    submitted_at: Date.new(2020, 10, 30))
      create(:application_work_experience,
             application_form: application_form_one,
             start_date: Date.new(2000, 1, 1),
             end_date: Date.new(2019, 1, 1))

      candidate_two = create(:candidate)
      application_form_two = create(:completed_application_form,
                                    candidate: candidate_two,
                                    date_of_birth: Date.new(1992, 4, 23),
                                    submitted_at: Date.new(2020, 10, 30))
      create(:application_work_experience,
             application_form: application_form_two,
             start_date: Date.new(2014, 10, 19),
             end_date: Date.new(2020, 10, 30))

      candidate_three = create(:candidate)
      create(:completed_application_form,
             candidate: candidate_three,
             date_of_birth: Date.new(1994, 7, 8),
             submitted_at: Date.new(2019, 1, 1))
      application_form_three = create(:completed_application_form,
                                      candidate: candidate_three,
                                      date_of_birth: Date.new(1994, 7, 8),
                                      submitted_at: Date.new(2020, 10, 30))
      create(:application_qualification,
             application_form: application_form_three,
             level: 'degree',
             start_year: 2012,
             award_year: 2015)
      create(:application_work_experience,
             application_form: application_form_three,
             start_date: Date.new(2015, 10, 19),
             end_date: Date.new(2020, 10, 30))

      candidate_four = create(:candidate)
      create(:completed_application_form,
             candidate: candidate_four,
             date_of_birth: Date.new(1994, 7, 8),
             submitted_at: Date.new(2019, 1, 1))
      application_form_four = create(:application_form,
                                     candidate: candidate_four,
                                     date_of_birth: Date.new(1994, 7, 8),
                                     submitted_at: Date.new(2020, 10, 30),
                                     work_history_completed: false)
      create(:application_qualification,
             application_form: application_form_four,
             level: 'degree',
             start_year: 2012,
             award_year: 2015)
      create(:application_work_experience,
             application_form: application_form_four,
             start_date: Date.new(2015, 10, 19),
             end_date: Date.new(2020, 10, 30))
      create(:application_choice, application_form: application_form_four, status: :cancelled)
      create(:application_choice, application_form: application_form_four, status: :recruited)

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          'Candidate id' => candidate_one.id,
          'Application id' => application_form_one.id,
          'Start of working life' => Date.new(2000, 1, 1),
          'Total unexplained time (months)' => 21,
          'Number of unexplained breaks' => 1,
          'Number of unexplained breaks in last 5 years' => 1,
          'Number of unexplained breaks that coincide with studying for a degree' => 0,
          'Work history completed' => true,
          'Course choice statuses' => [],
        },
        {
          'Candidate id' => candidate_two.id,
          'Application id' => application_form_two.id,
          'Start of working life' => Date.new(2010, 4, 1),
          'Total unexplained time (months)' => 55,
          'Number of unexplained breaks' => 1,
          'Number of unexplained breaks in last 5 years' => 0,
          'Number of unexplained breaks that coincide with studying for a degree' => 0,
          'Work history completed' => true,
          'Course choice statuses' => [],
        },
        {
          'Candidate id' => candidate_three.id,
          'Application id' => application_form_three.id,
          'Start of working life' => Date.new(2012, 7, 1),
          'Total unexplained time (months)' => 40,
          'Number of unexplained breaks' => 1,
          'Number of unexplained breaks in last 5 years' => 0,
          'Number of unexplained breaks that coincide with studying for a degree' => 1,
          'Work history completed' => true,
          'Course choice statuses' => [],
        },
        {
          'Candidate id' => candidate_four.id,
          'Application id' => application_form_four.id,
          'Start of working life' => Date.new(2012, 7, 1),
          'Total unexplained time (months)' => 40,
          'Number of unexplained breaks' => 1,
          'Number of unexplained breaks in last 5 years' => 0,
          'Number of unexplained breaks that coincide with studying for a degree' => 1,
          'Work history completed' => false,
          'Course choice statuses' => %w[cancelled recruited],
        },
      )
    end
  end
end
