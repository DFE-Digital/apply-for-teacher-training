require 'rails_helper'

RSpec.describe CandidateInterface::RestructuredWorkHistory::ReviewComponent do
  around do |example|
    Timecop.freeze(Time.zone.now) do
      example.run
    end
  end

  let(:application_form_with_no_breaks) do
    build_stubbed(
      :application_form,
      application_work_experiences: [
        build_stubbed(:application_work_experience, role: 'Teaching Assistant', organisation: 'Vararu Schools', start_date: 9.months.ago, end_date: 4.months.ago),
        build_stubbed(:application_work_experience, role: 'Teaching Assistant', organisation: 'Theo Schools', start_date: 4.months.ago, end_date: 2.months.ago),
        build_stubbed(:application_work_experience, role: 'Teaching Assistant', organisation: 'Vararu Schools', start_date: 2.months.ago, end_date: Time.zone.now),
      ],
    )
  end

  let(:application_form_with_break) do
    build_stubbed(
      :application_form,
      application_work_history_breaks: [
        build_stubbed(
          :application_work_history_break,
          start_date: 8.months.ago,
          end_date: 6.months.ago,
          reason: 'WE WERE ON A BREAK!',
        ),
      ],
      application_work_experiences: [
        build_stubbed(:application_work_experience, start_date: 5.years.ago, end_date: 59.months.ago),
        build_stubbed(:application_work_experience, start_date: 2.months.ago, end_date: 1.month.ago),
      ],
    )
  end

  let(:application_form_with_no_experience) do
    build_stubbed(
      :application_form,
      work_history_explanation: 'I no work.',
    )
  end

  let(:application_form_with_gap_and_no_break_added) do
    build_stubbed(
      :application_form,
      application_work_experiences: [
        build_stubbed(:application_work_experience, start_date: 5.years.ago, end_date: 59.months.ago),
        build_stubbed(:application_work_experience, start_date: 2.months.ago, end_date: 1.month.ago),
      ],
    )
  end

  context 'when the application is editable' do
    context 'when there is not a break in the work history' do
      it 'renders component with correct structure' do
        result = render_inline(described_class.new(application_form: application_form_with_no_breaks))

        application_form_with_no_breaks.application_work_experiences.each do |work|
          expect(result.text).to include(work.role)
          expect(result.text).to include(work.start_date.to_s(:short_month_and_year))
          if work.relevant_skills
            expect(result.text).to include('This role used skills relevant to teaching')
          end
        end
      end
    end

    context 'when there is a work break present' do
      it 'renders component with change and delete links' do
        result = render_inline(described_class.new(application_form: application_form_with_break))

        expect(result.text).to include('WE WERE ON A BREAK!')
        expect(result.text).to include("Delete entry for break between #{8.months.ago.to_s(:short_month_and_year)} and #{6.months.ago.to_s(:short_month_and_year)}")
        expect(result.text).to include("Change entry for break between #{8.months.ago.to_s(:short_month_and_year)} and #{6.months.ago.to_s(:short_month_and_year)}")
      end
    end

    context 'when there is a gap in work history' do
      it 'renders component with break placeholders' do
        result = render_inline(described_class.new(application_form: application_form_with_gap_and_no_break_added, editable: true))

        expect(result.text).to include('You have a break in your work history (4 years and 8 months)')
      end
    end

    context 'when there is no work experience' do
      it 'renders component asking for an explanation' do
        result = render_inline(described_class.new(application_form: application_form_with_no_experience))

        expect(result.text).to include('Explanation of why you’ve been out of the workplace')
        expect(result.text).to include('I no work.')
        expect(result.text).to include('Change explanation of why you’ve been out of the workplace')
      end
    end
  end

  context 'when the application is not editable' do
    context 'when there is not a break in the work history' do
      it 'renders component without an edit link' do
        result = render_inline(described_class.new(application_form: application_form_with_no_breaks, editable: false))

        expect(result.text).not_to include('Change job Teaching Assistant for Vararu School')
        expect(result.text).not_to include('Delete job Teaching Assistant for Vararu School')
      end
    end

    context 'when there is a work break present' do
      it 'renders component without change and delete links' do
        result = render_inline(described_class.new(application_form: application_form_with_break, editable: false))

        expect(result.text).to include('WE WERE ON A BREAK!')
        expect(result.text).not_to include('Delete entry for break between Feb 2019 and Apr 2019')
        expect(result.text).not_to include('Change entry for break between Feb 2019 and Apr 2019')
      end
    end

    context 'when there is a gap in work history' do
      it 'renders component without break placeholders' do
        result = render_inline(described_class.new(application_form: application_form_with_gap_and_no_break_added, editable: false))

        expect(result.text).not_to include('You have a break in your work history (4 years and 8 months)')
      end
    end

    context 'when there is no work experience' do
      it 'renders component asking for an explanation' do
        result = render_inline(described_class.new(application_form: application_form_with_no_experience, editable: false))

        expect(result.text).to include('Explanation of why you’ve been out of the workplace')
        expect(result.text).to include('I no work.')
        expect(result.text).not_to include('Change explanation')
      end
    end
  end
end
