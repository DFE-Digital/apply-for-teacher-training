require 'rails_helper'

RSpec.describe CheckBreaksInWorkHistory do
  describe '.call' do
    let(:november2018) { Time.zone.local(2018, 11, 1) }
    let(:december2018) { Time.zone.local(2018, 12, 1) }
    let(:january2019) { Time.zone.local(2019, 1, 1) }
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:march2019) { Time.zone.local(2019, 3, 1) }
    let(:june2019) { Time.zone.local(2019, 6, 1) }
    let(:july2019) { Time.zone.local(2019, 7, 1) }
    let(:august2019) { Time.zone.local(2019, 8, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:october2019) { Time.zone.local(2019, 10, 1) }
    let(:november2019) { Time.zone.local(2019, 11, 1) }

    around do |example|
      Timecop.freeze(Time.zone.local(2019, 11, 15)) do
        example.run
      end
    end

    context 'when there are no jobs' do
      it 'returns false' do
        application_form = build_stubbed(:application_form)

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(false)
      end
    end

    context 'when there is only one job' do
      it 'returns false if the job is current role i.e. end date is nil' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: september2019,
            end_date: nil,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(false)
      end

      it 'returns false if the job ends at current date' do
        current_date = october2019

        Timecop.freeze(current_date) do
          application_form = create(:application_form) do |form|
            form.application_work_experiences.create(
              start_date: september2019,
              end_date: current_date,
            )
          end

          breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

          expect(breaks_in_work_history).to eq(false)
        end
      end

      it 'returns true if the job ends exactly a month before current date' do
        current_date = october2019

        Timecop.freeze(current_date) do
          application_form = create(:application_form) do |form|
            form.application_work_experiences.create(
              start_date: august2019,
              end_date: september2019,
            )
          end

          breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

          expect(breaks_in_work_history).to eq(true)
        end
      end

      it 'returns true if the job ends more than a month before current date' do
        current_date = october2019

        Timecop.freeze(current_date) do
          application_form = create(:application_form) do |form|
            form.application_work_experiences.create(
              start_date: january2019,
              end_date: march2019,
            )
          end

          breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

          expect(breaks_in_work_history).to eq(true)
        end
      end
    end

    context 'when there are two jobs' do
      it 'returns true if there is exactly a month break between the jobs' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: december2018,
          )

          form.application_work_experiences.create(
            start_date: january2019,
            end_date: november2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(true)
      end

      it 'returns true if there is more than a month break between the jobs' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: december2018,
          )

          form.application_work_experiences.create(
            start_date: february2019,
            end_date: march2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(true)
      end

      it 'returns true if the second job ended more than a month ago' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: december2018,
          )

          form.application_work_experiences.create(
            start_date: december2018,
            end_date: february2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(true)
      end

      it 'returns false if the second job ended more than a month ago but the first job is current' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: nil,
          )

          form.application_work_experiences.create(
            start_date: december2018,
            end_date: february2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(false)
      end

      it 'returns true if there is a break regardless of creation order' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: february2019,
            end_date: march2019,
          )

          form.application_work_experiences.create(
            start_date: november2018,
            end_date: december2018,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(true)
      end
    end

    context 'when there are more than two jobs' do
      it 'returns false if no breaks in work history' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: january2019,
            end_date: june2019,
          )

          form.application_work_experiences.create(
            start_date: june2019,
            end_date: august2019,
          )

          form.application_work_experiences.create(
            start_date: august2019,
            end_date: november2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(false)
      end

      it 'returns true if there are breaks in work history' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: january2019,
          )

          form.application_work_experiences.create(
            start_date: january2019,
            end_date: march2019,
          )

          form.application_work_experiences.create(
            start_date: june2019,
            end_date: september2019,
          )

          form.application_work_experiences.create(
            start_date: september2019,
            end_date: november2019,
          )

          form.application_work_experiences.create(
            start_date: november2019,
            end_date: nil,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(true)
      end

      it 'returns false if there are breaks in work history covered by current job' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: january2019,
          )

          form.application_work_experiences.create(
            start_date: january2019,
            end_date: nil,
          )

          form.application_work_experiences.create(
            start_date: june2019,
            end_date: july2019,
          )

          form.application_work_experiences.create(
            start_date: september2019,
            end_date: november2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(false)
      end

      it 'returns false if there are breaks in work history overlapped by an earlier job' do
        application_form = create(:application_form) do |form|
          form.application_work_experiences.create(
            start_date: november2018,
            end_date: january2019,
          )

          form.application_work_experiences.create(
            start_date: january2019,
            end_date: october2019,
          )

          form.application_work_experiences.create(
            start_date: june2019,
            end_date: july2019,
          )

          form.application_work_experiences.create(
            start_date: september2019,
            end_date: november2019,
          )
        end

        breaks_in_work_history = CheckBreaksInWorkHistory.call(application_form)

        expect(breaks_in_work_history).to eq(false)
      end
    end
  end
end
