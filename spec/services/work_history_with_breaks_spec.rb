require 'rails_helper'

RSpec.describe WorkHistoryWithBreaks do
  describe '#timeline' do
    let(:january2014) { Time.zone.local(2014, 1, 1) }
    let(:march2014) { Time.zone.local(2014, 3, 1) }
    let(:october2014) { Time.zone.local(2014, 10, 1) }
    let(:february2015) { Time.zone.local(2015, 2, 1) }
    let(:february2016) { Time.zone.local(2016, 2, 1) }
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:april2019) { Time.zone.local(2019, 4, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:october2019) { Time.zone.local(2019, 10, 1) }
    let(:november2019) { Time.zone.local(2019, 11, 1) }
    let(:december2019) { Time.zone.local(2019, 12, 1) }
    let(:january2020) { Time.zone.local(2020, 1, 1) }
    let(:february2020) { Time.zone.local(2020, 2, 1) }
    let(:april2020) { Time.zone.local(2020, 4, 1) }
    let(:current_date) { Time.zone.now }
    let(:submitted_at) { february2020 }
    let(:work_history_with_breaks) { described_class.new(application_form).timeline }
    let(:application_form) do
      build_stubbed(:application_form,
                    application_work_experiences: work_history,
                    application_work_history_breaks: breaks,
                    submitted_at: submitted_at)
    end
    let(:breaks) { [] }
    let(:work_history) { [] }

    context 'when :include_unpaid_experience is enabled' do
      let(:work_history_with_breaks) { described_class.new(application_form, include_unpaid_experience: true) }
      let(:application_form) do
        build_stubbed(:application_form,
                      application_work_experiences: work_history,
                      application_work_history_breaks: breaks,
                      application_volunteering_experiences: volunteering_experiences,
                      submitted_at: submitted_at)
      end
      let(:volunteering_experiences) { [] }

      describe '#initialize' do
        let(:volunteering_experiences) { build_stubbed_list(:application_volunteering_experience, 2) }

        it 'returns volunteering experiences for #unpaid_work and sorts them by start_date' do
          expect(work_history_with_breaks.unpaid_work).to eq(application_form.application_volunteering_experiences.sort_by(&:start_date))
        end
      end

      describe '#timeline' do
        let(:volunteering_experience1) { build_stubbed(:application_volunteering_experience, start_date: february2019) }
        let(:volunteering_experience2) { build_stubbed(:application_volunteering_experience, start_date: february2020) }
        let(:volunteering_experiences) { [volunteering_experience1, volunteering_experience2] }
        let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: nil) }
        let(:job2) { build_stubbed(:application_work_experience, start_date: september2019, end_date: nil) }
        let(:work_history) { [job1, job2] }

        it 'renders both paid and unpaid experieence in descending order by start date' do
          timeline = work_history_with_breaks.timeline

          expect(timeline.count).to eq(4)
          expect(timeline[0]).to eq(volunteering_experience2)
          expect(timeline[1]).to eq(job2)
          expect(timeline[2]).to eq(volunteering_experience1)
          expect(timeline[3]).to eq(job1)
        end
      end
    end

    context 'when there are no jobs' do
      it 'returns an empty array' do
        expect(work_history_with_breaks).to eq([])
      end
    end

    context 'when there is one job with a nil end date' do
      let(:job) { build_stubbed(:application_work_experience, start_date: february2015, end_date: nil) }
      let(:work_history) { [job] }

      it 'returns the job' do
        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(job)
      end
    end

    context 'when there is one job that ends at current date' do
      let(:job) { build_stubbed(:application_work_experience, start_date: february2015, end_date: current_date) }
      let(:work_history) { [job] }

      it 'returns the job' do
        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(job)
      end
    end

    context 'when there is one job that ends at submission_date' do
      let(:job) { build_stubbed(:application_work_experience, start_date: february2015, end_date: february2020) }
      let(:work_history) { [job] }

      it 'returns the job' do
        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to eq(job)
      end
    end

    context 'when there is one job and a one month break between the end date and current date' do
      let(:job) { build_stubbed(:application_work_experience, start_date: february2015, end_date: december2019) }
      let(:work_history) { [job] }

      it 'returns the job then a break placeholder with a length of one month' do
        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job)
        expect(work_history_with_breaks[1]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[1].length).to eq(1)
        expect(work_history_with_breaks[1].start_date).to eq(Date.new(2019, 12, 1))
        expect(work_history_with_breaks[1].end_date).to eq(Date.new(2020, 2, 1))
      end
    end

    context 'when there is one job and more than a month break between the end date and current date' do
      let(:job) { build_stubbed(:application_work_experience, start_date: february2015, end_date: october2019) }
      let(:work_history) { [job] }

      it 'returns the job then a break placeholder with a length of three months' do
        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job)
        expect(work_history_with_breaks[1]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[1].length).to eq(3)
      end
    end

    context 'when there are multiple jobs with no breaks' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: october2019) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: october2019, end_date: december2019) }
      let(:job3) { build_stubbed(:application_work_experience, start_date: january2020, end_date: current_date) }
      let(:work_history) { [job1, job2, job3] }

      it 'returns all jobs and sorted by start date' do
        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to eq(job3)
      end
    end

    context 'when there is a break between two jobs' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: october2019) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: october2019, end_date: november2019) }
      let(:job3) { build_stubbed(:application_work_experience, start_date: january2020, end_date: current_date) }
      let(:work_history) { [job1, job2, job3] }

      it 'returns all jobs with a break inbetween two jobs' do
        expect(work_history_with_breaks.count).to eq(4)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[2].length).to eq(1)
        expect(work_history_with_breaks[3]).to eq(job3)
      end
    end

    context 'when there is a break between two jobs but outside of the last 5 years' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: january2014, end_date: march2014) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: october2014, end_date: current_date) }
      let(:work_history) { [job1, job2] }

      it 'returns all jobs without a break' do
        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
      end
    end

    context 'when the first job is the current job and there is a break between following jobs' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: nil) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: april2019, end_date: september2019) }
      let(:job3) { build_stubbed(:application_work_experience, start_date: november2019, end_date: december2019) }
      let(:work_history) { [job1, job2, job3] }

      it 'returns all jobs without a break as current job covers the break between following jobs' do
        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to eq(job3)
      end
    end

    context 'when there is a break before the current job and a break between following jobs' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: february2019) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: april2019, end_date: nil) }
      let(:job3) { build_stubbed(:application_work_experience, start_date: november2019, end_date: december2019) }
      let(:work_history) { [job1, job2, job3] }

      it 'returns only the break before the current job as current job covers the break between following jobs' do
        expect(work_history_with_breaks.count).to eq(4)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to be_instance_of(WorkHistoryWithBreaks::BreakPlaceholder)
        expect(work_history_with_breaks[1].length).to eq(1)
        expect(work_history_with_breaks[2]).to eq(job2)
        expect(work_history_with_breaks[3]).to eq(job3)
      end
    end

    context 'when there is one job that covers the break between following jobs' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: december2019) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: april2019, end_date: september2019) }
      let(:job3) { build_stubbed(:application_work_experience, start_date: november2019, end_date: nil) }
      let(:work_history) { [job1, job2, job3] }

      it 'returns all jobs without a break' do
        expect(work_history_with_breaks.count).to eq(3)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to eq(job2)
        expect(work_history_with_breaks[2]).to eq(job3)
      end
    end

    context 'when there are multiple jobs and an existing break' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: february2019) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: april2019, end_date: nil) }
      let(:breaks) { [build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)] }
      let(:work_history) { [job1, job2] }

      it 'returns all jobs and the existing break and sorted by start date' do
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
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: february2019) }
      let(:job2) { build_stubbed(:application_work_experience, start_date: april2019, end_date: nil) }
      let(:breaks) { [build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)] }

      it 'returns the existing break' do
        expect(work_history_with_breaks.count).to eq(1)
        expect(work_history_with_breaks[0]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[0].start_date).to eq(february2019)
        expect(work_history_with_breaks[0].end_date).to eq(april2019)
        expect(work_history_with_breaks[0].length).to eq(1)
      end
    end

    context 'when there are no jobs and multiple existing breaks' do
      let(:break1) { build_stubbed(:application_work_history_break, start_date: november2019, end_date: submitted_at) }
      let(:break2) { build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019) }
      let(:breaks) { [break1, break2] }

      it 'returns all existing breaks and sorted by start date' do
        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[0].start_date).to eq(february2019)
        expect(work_history_with_breaks[0].end_date).to eq(april2019)
        expect(work_history_with_breaks[0].length).to eq(1)
        expect(work_history_with_breaks[1]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[1].start_date).to eq(november2019)
        expect(work_history_with_breaks[1].end_date).to eq(submitted_at)
        expect(work_history_with_breaks[1].length).to eq(2)
      end
    end

    context 'when there is an existing break that overlaps with a job' do
      let(:job1) { build_stubbed(:application_work_experience, start_date: february2015, end_date: february2016) }
      let(:work_history) { [job1] }
      let(:breaks) { [build_stubbed(:application_work_history_break, start_date: february2015, end_date: submitted_at)] }

      it 'returns the job and existing break, it does not include a break placeholder' do
        expect(work_history_with_breaks.count).to eq(2)
        expect(work_history_with_breaks[0]).to eq(job1)
        expect(work_history_with_breaks[1]).to be_instance_of(ApplicationWorkHistoryBreak)
        expect(work_history_with_breaks[1].start_date).to eq(february2015)
        expect(work_history_with_breaks[1].end_date).to eq(submitted_at)
        expect(work_history_with_breaks[1].length).to eq(59)
      end
    end
  end
end
