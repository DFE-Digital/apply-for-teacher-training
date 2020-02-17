require 'rails_helper'

RSpec.describe WorkHistoryWithBreaks do
  describe '#timeline' do
    let(:january2014) { Time.zone.local(2014, 1, 1) }
    let(:march2014) { Time.zone.local(2014, 3, 1) }
    let(:october2014) { Time.zone.local(2014, 10, 1) }
    let(:february2015) { Time.zone.local(2015, 2, 1) }
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

    context 'when there is one job with a nil end date i.e. current job' do
      it 'returns the job' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: nil)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(job1)
      end
    end

    context 'when there is one job that ends at current date i.e. current job' do
      it 'returns the job' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: current_date)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(job1)
      end
    end

    context 'when there is one job and a one month break between the end date and current date' do
      it 'returns the job then a break placeholder with a length of one month' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: december2019)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[1].length).to eq(1)
        expect(work_history_with_breaks[1].start_date).to eq(Date.new(2019, 12, 1))
        expect(work_history_with_breaks[1].end_date).to eq(Date.new(2020, 2, 1))
      end
    end

    context 'when there is one job and more than a month break between the end date and current date' do
      it 'returns the job then a break placeholder with a length of three months' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: october2019)
        work_history = [job1]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[1].length).to eq(3)
      end
    end

    context 'when there are multiple jobs with no breaks' do
      it 'returns all jobs and sorted by start date' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: october2019)
        job2 = build_stubbed(:application_work_experience, start_date: october2019, end_date: december2019)
        job3 = build_stubbed(:application_work_experience, start_date: january2020, end_date: current_date)
        work_history = [job2, job1, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to eq(job3)
      end
    end

    context 'when there is a break between two jobs' do
      it 'returns all jobs with a break inbetween two jobs' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: october2019)
        job2 = build_stubbed(:application_work_experience, start_date: october2019, end_date: november2019)
        job3 = build_stubbed(:application_work_experience, start_date: january2020, end_date: current_date)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(4)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[2].length).to eq(1)
        expect(work_history_with_breaks[3]).to eq(job3)
      end
    end

    context 'when there is a break between two jobs but outside of the last 5 years' do
      it 'returns all jobs without a break' do
        job1 = build_stubbed(:application_work_experience, start_date: january2014, end_date: march2014)
        job2 = build_stubbed(:application_work_experience, start_date: october2014, end_date: current_date)
        work_history = [job1, job2]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
      end
    end

    context 'when the first job is the current job and there is a break between following jobs' do
      it 'returns all jobs without a break as current job covers the break between following jobs' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: nil)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: september2019)
        job3 = build_stubbed(:application_work_experience, start_date: november2019, end_date: december2019)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to eq(job3)
      end
    end

    context 'when there is a break before the current job and a break between following jobs' do
      it 'returns only the break before the current job as current job covers the break between following jobs' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: february2019)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: nil)
        job3 = build_stubbed(:application_work_experience, start_date: november2019, end_date: december2019)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(4)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[1].length).to eq(1)
        expect(work_history_with_breaks[2]).to eq(job2)
        expect(work_history_with_breaks[3]).to eq(job3)
      end
    end

    context 'when there is one job that covers the break between following jobs' do
      it 'returns all jobs without a break' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: december2019)
        job2 = build_stubbed(:application_work_experience, start_date: april2019, end_date: september2019)
        job3 = build_stubbed(:application_work_experience, start_date: november2019, end_date: nil)
        work_history = [job1, job2, job3]
        application_form = build_stubbed(:application_form, application_work_experiences: work_history)

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to eq(job3)
      end
    end

    context 'when there are multiple jobs and an existing break' do
      it 'returns all jobs and the existing break and sorted by start date' do
        job1 = build_stubbed(:application_work_experience, start_date: february2015, end_date: february2019)
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
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[1].start_date).to eq(february2019)
        expect(work_history_with_breaks[1].end_date).to eq(april2019)
        expect(work_history_with_breaks[1].length).to eq(1)
        expect(work_history_with_breaks[2]).to eq(job2)
      end
    end

    context 'when there are no jobs but an existing break' do
      it 'returns the existing break' do
        work_history = []
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)
        breaks = [break1]
        application_form = build_stubbed(
          :application_form,
          application_work_experiences: work_history,
          application_work_history_breaks: breaks,
        )

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[0].start_date).to eq(february2019)
        expect(work_history_with_breaks[0].end_date).to eq(april2019)
        expect(work_history_with_breaks[0].length).to eq(1)
      end
    end

    context 'when there are no jobs and multiple existing breaks' do
      it 'returns all existing breaks and sorted by start date' do
        work_history = []
        break1 = build_stubbed(:application_work_history_break, start_date: november2019, end_date: current_date)
        break2 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)
        breaks = [break2, break1]
        application_form = build_stubbed(
          :application_form,
          application_work_experiences: work_history,
          application_work_history_breaks: breaks,
        )

        get_work_history_with_breaks = WorkHistoryWithBreaks.new(application_form)
        work_history_with_breaks = get_work_history_with_breaks.timeline

        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[0].start_date).to eq(february2019)
        expect(work_history_with_breaks[0].end_date).to eq(april2019)
        expect(work_history_with_breaks[0].length).to eq(1)
        expect(work_history_with_breaks[1]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[1].start_date).to eq(november2019)
        expect(work_history_with_breaks[1].end_date).to eq(current_date)
        expect(work_history_with_breaks[1].length).to eq(2)
      end
    end
  end
end
