require 'rails_helper'

RSpec.describe EndOfCycle::CancelUnsubmittedApplicationsWorker do
  describe '#perform' do
    let(:unsubmitted_application_from_this_year) do
      create(:application_form,
             submitted_at: nil,
             recruitment_cycle_year: current_year,
             application_choices: [create_an_application_choice(:unsubmitted, current_year_course_option)])
    end

    let(:unsubmitted_application_from_last_year) do
      create(:application_form,
             submitted_at: nil,
             recruitment_cycle_year: previous_year,
             application_choices: [create_an_application_choice(:unsubmitted, previous_year_course_option)])
    end

    let(:previous_year_course_option) do
      create(:course_option,
             course: create(:course,
                            recruitment_cycle_year: previous_year))
    end

    let(:current_year_course_option) do
      create(:course_option,
             course: create(:course,
                            recruitment_cycle_year: current_year))
    end

    let(:hidden_application_from_this_year) do
      create(:application_form,
             submitted_at: nil,
             candidate: create(:candidate, hide_in_reporting: true),
             recruitment_cycle_year: current_year,
             application_choices: [create_an_application_choice(:unsubmitted, current_year_course_option)])
    end

    let(:rejected_application_from_this_year) do
      create(:application_form,
             recruitment_cycle_year: current_year,
             application_choices: [create_an_application_choice(:rejected, current_year_course_option)])
    end

    let(:unsubmitted_cancelled_application_from_this_year) do
      create(:application_form,
             submitted_at: nil,
             recruitment_cycle_year: current_year,
             application_choices: [create_an_application_choice(:application_not_sent, current_year_course_option)])
    end

    let(:create_test_applications) do
      unsubmitted_cancelled_application_from_this_year
      rejected_application_from_this_year
      hidden_application_from_this_year
      unsubmitted_application_from_last_year
      unsubmitted_application_from_this_year
    end

    context 'when force is true', time: mid_cycle do
      it 'allows job to be run' do
        create_test_applications
        allow(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).to receive(:perform_at)
        described_class.new.perform(force: true)
        expect(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker)
          .to have_received(:perform_at)
                .with(
                  kind_of(Time),
                  contain_exactly(
                    unsubmitted_application_from_this_year.id,
                    hidden_application_from_this_year.id,
                  ),
                )
      end
    end

    context 'for previous cycle, current cycle' do
      [previous_year, current_year].each do |year|
        context 'on cancel application deadline', time: cancel_application_deadline(year) do
          it 'cancels applications' do
            create_test_applications

            allow(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker)
              .to have_received(:perform_at)
                    .with(
                      kind_of(Time),
                      contain_exactly(
                        unsubmitted_application_from_this_year.id,
                        hidden_application_from_this_year.id,
                      ),
                    )
          end
        end

        context 'between cycles, but not on cancel date', time: after_apply_deadline(year) do
          it 'does not cancel any applications' do
            create_test_applications

            allow(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not run once in the middle of a cycle' do
            create_test_applications

            allow(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not run once the new cycle starts' do
            create_test_applications

            allow(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker).not_to have_received(:perform_at)
          end
        end
      end
    end
  end

  def create_an_application_choice(status, course_option)
    create(
      :application_choice,
      status: status,
      course_option: course_option,
    )
  end
end
