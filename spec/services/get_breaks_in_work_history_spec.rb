require 'rails_helper'

RSpec.describe GetBreaksInWorkHistory do
  describe '.call' do
    let(:jan2019) { Time.zone.local(2019, 1, 1) }
    let(:nov2019) { Time.zone.local(2019, 11, 1) }
    let(:dec2019) { Time.zone.local(2019, 12, 1) }

    context 'when there are no jobs' do
      it 'returns no breaks' do
        application_form = build_stubbed(:application_form)

        breaks_in_work_history = GetBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq({})
      end
    end

    context 'when there is only one job' do
      it 'returns no breaks if the job is current role i.e. end date is nil' do
        application_form = create(:completed_application_form, work_experiences_count: 1)

        application_form.application_work_experiences[0].update(
          start_date: jan2019,
          end_date: nil, # it is the current role
        )

        breaks_in_work_history = GetBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history.size).to eq 0
      end
    end

    context 'when there is only one job' do
      it 'returns the number of months between end_of_date and current date' do
        application_form = create(:completed_application_form, work_experiences_count: 2)

        application_form.application_work_experiences[0].update(
          start_date: jan2019,
          end_date: jan2019 + 3.months, # March 2019
        )

        application_form.application_work_experiences[1].update(
          start_date: jan2019 + 6.months,
          end_date: nil, # current work
        )

        work_ids = application_form.application_work_experiences.pluck(:id)

        Timecop.freeze(dec2019) do
          breaks_in_work_history = GetBreaksInWorkHistory.call(application_form)

          expect(breaks_in_work_history.size).to eq(1)

          expect(breaks_in_work_history[work_ids[0]]).to eq(2) # 4 months gap
        end
      end
    end
  end
end
