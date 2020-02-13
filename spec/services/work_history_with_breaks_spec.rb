require 'rails_helper'

RSpec.describe WorkHistoryWithBreaks do
  describe '#call' do
    let(:january2019) { Time.zone.local(2019, 1, 1) }
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:march2019) { Time.zone.local(2019, 3, 1) }
    let(:april2019) { Time.zone.local(2019, 4, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:october2019) { Time.zone.local(2019, 10, 1) }
    let(:november2019) { Time.zone.local(2019, 11, 1) }
    let(:december2019) { Time.zone.local(2019, 12, 1) }
    let(:january2020) { Time.zone.local(2020, 1, 1) }
    let(:february2020) { Time.zone.local(2020, 2, 1) }
    let(:current_date) { february2020 }

    around do |example|
      Timecop.freeze(current_date) do
        example.run
      end
    end

    context 'when there are no jobs' do
      it 'returns an empty array' do
        work_history = []
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks).to eq([])
      end
    end

    context 'when there is only one job' do
      it 'returns an array containing a hash if the job is current role i.e. end date is nil' do
        job1 = build_stubbed(:application_work_experience, start_date: september2019, end_date: nil)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
      end

      it 'returns an array containing a hash if the job ends at current date' do
        job1 = build_stubbed(:application_work_experience, start_date: september2019, end_date: current_date)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
      end

      it 'returns an array containing a hash for a job and a break if one month break' do
        job1 = build_stubbed(:application_work_experience, start_date: september2019, end_date: december2019)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1][:type]).to eq(:break_placeholder)
        expect(work_history_with_breaks[1][:entry].length).to eq(1)
        expect(work_history_with_breaks[1][:entry].start_date).to eq(Date.new(2019, 12, 1))
        expect(work_history_with_breaks[1][:entry].end_date).to eq(Date.new(2020, 2, 1))
      end

      it 'returns an array containing a hash for a job and a break if more than a month break' do
        job1 = build_stubbed(:application_work_experience, start_date: september2019, end_date: october2019)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1][:type]).to eq(:break_placeholder)
        expect(work_history_with_breaks[1][:entry].length).to eq(3)
      end
    end

    context 'when there are multiple jobs' do
      it 'returns an array containing hashes for jobs if there are no breaks' do
        job1 = build_stubbed(:application_work_experience, start_date: september2019, end_date: october2019)
        job2 = build_stubbed(:application_work_experience, start_date: october2019, end_date: december2019)
        job3 = build_stubbed(:application_work_experience, start_date: january2020, end_date: current_date)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1]).to eq(type: :job, entry: job2)
        expect(work_history_with_breaks[2]).to eq(type: :job, entry: job3)
      end

      it 'returns an array containing hashes for jobs and a break if there is a break' do
        job1 = build_stubbed(:application_work_experience, start_date: september2019, end_date: october2019)
        job2 = build_stubbed(:application_work_experience, start_date: october2019, end_date: november2019)
        job3 = build_stubbed(:application_work_experience, start_date: january2020, end_date: current_date)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(4)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1]).to eq(type: :job, entry: job2)
        expect(work_history_with_breaks[2][:type]).to eq(:break_placeholder)
        expect(work_history_with_breaks[2][:entry].length).to eq(1)
        expect(work_history_with_breaks[3]).to eq(type: :job, entry: job3)
      end

      it 'returns an array containing hashes for jobs if current job covers breaks between following jobs' do
        job1 = build_stubbed(:application_work_experience, start_date: march2019, end_date: nil)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: september2019)
        job3 = build_stubbed(:application_work_experience, start_date: november2019, end_date: december2019)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1]).to eq(type: :job, entry: job2)
        expect(work_history_with_breaks[2]).to eq(type: :job, entry: job3)
      end

      it 'returns an array containing hashes for jobs and a break if current job covers break between job after and present' do
        job1 = build_stubbed(:application_work_experience, start_date: january2019, end_date: february2019)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: nil)
        job3 = build_stubbed(:application_work_experience, start_date: november2019, end_date: december2019)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(4)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1][:type]).to eq(:break_placeholder)
        expect(work_history_with_breaks[1][:entry].length).to eq(1)
        expect(work_history_with_breaks[2]).to eq(type: :job, entry: job2)
        expect(work_history_with_breaks[3]).to eq(type: :job, entry: job3)
      end

      it 'returns an array containing hashes for jobs if previous job covers break between job after and present' do
        job1 = build_stubbed(:application_work_experience, start_date: january2019, end_date: december2019)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: september2019)
        job3 = build_stubbed(:application_work_experience, start_date: november2019, end_date: nil)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1]).to eq(type: :job, entry: job2)
        expect(work_history_with_breaks[2]).to eq(type: :job, entry: job3)
      end
    end

    context 'when an application form already has a break' do
      it 'returns an array containing hashes for jobs and the existing break' do
        job1 = build_stubbed(:application_work_experience, start_date: january2019, end_date: february2019)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: nil)
        work_history = [job1, job2]
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)
        breaks = [break1]
        application_form = build_stubbed(
          :application_form,
          application_work_experiences: work_history,
          application_work_history_breaks: breaks,
        )

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(type: :job, entry: job1)
        expect(work_history_with_breaks[1][:type]).to eq(:break)
        expect(work_history_with_breaks[1][:entry].start_date).to eq(february2019)
        expect(work_history_with_breaks[1][:entry].end_date).to eq(april2019)
        expect(work_history_with_breaks[1][:entry].length).to eq(1)
        expect(work_history_with_breaks[2]).to eq(type: :job, entry: job2)
      end
    end
  end
end
