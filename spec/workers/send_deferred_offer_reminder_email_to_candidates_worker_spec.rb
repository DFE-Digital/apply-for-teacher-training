require 'rails_helper'

RSpec.describe SendDeferredOfferReminderEmailToCandidatesWorker, :sidekiq do
  let(:course_this_year) { create(:course, recruitment_cycle_year: current_year) }
  let(:course_last_year) { create(:course, recruitment_cycle_year: previous_year) }

  describe '#perform' do
    it 'sends reminder emails to all candidates with deferred offers from the previous cycle' do
      candidate1 = create(:candidate)
      candidate2 = create(:candidate)
      candidate3 = create(:candidate)

      create(
        :application_choice,
        :offer_deferred,
        course_option: create(
          :course_option,
          course: course_this_year,
        ),
        application_form: application_form(candidate1),
      )
      create(
        :application_choice,
        :offer_deferred,
        course_option: create(
          :course_option,
          course: course_last_year,
        ),
        application_form: application_form(candidate2),
      )
      create(
        :application_choice,
        :offer_deferred,
        offer_deferred_at: Time.zone.local(2019, 4, 13),
        course_option: create(
          :course_option,
          course: course_last_year,
        ),
        application_form: application_form(candidate3),
      )

      described_class.new.perform

      expect(email_for_candidate(candidate1)).not_to be_present

      expect(email_for_candidate(candidate2)).to be_present

      email_for_candidate3 = email_for_candidate(candidate3)
      expect(email_for_candidate3).to be_present
      expect(email_for_candidate3.subject).to include 'Reminder of your deferred offer'
      expect(email_for_candidate3.body).to include 'On 13 April 2019'
    end
  end

  def application_form(candidate)
    create(:completed_application_form, candidate:)
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
