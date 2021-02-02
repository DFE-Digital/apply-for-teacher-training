require 'rails_helper'

RSpec.describe CandidateInterface::RestructuredWorkHistoryReviewComponent do
  around do |example|
    Timecop.freeze(Time.zone.local(2019, 10, 1)) do
      example.run
    end
  end

  let(:february2019) { Time.zone.local(2019, 2, 1) }
  let(:april2019) { Time.zone.local(2019, 4, 1) }
  let(:data) do
    {
      role: 'Teaching Assistant',
      organisation: Faker::Educator.secondary_school,
      details: Faker::Lorem.paragraph_by_chars(number: 300),
      commitment: %w[full_time part_time].sample,
      relevant_skills: [true, true, true, false].sample,
    }
  end

  let(:application_form_with_no_breaks) do
    create(:application_form) do |form|
      data[:organisation] = 'Vararu School'
      data[:start_date] = Time.zone.local(2019, 1, 1)
      data[:end_date] = Time.zone.local(2019, 6, 1)
      form.application_work_experiences.create(data)

      data[:organisation] = 'Theo School'
      data[:start_date] = Time.zone.local(2019, 6, 1)
      data[:end_date] = Time.zone.local(2019, 8, 1)
      form.application_work_experiences.create(data)

      data[:organisation] = 'Vararu School'
      data[:start_date] = Time.zone.local(2019, 8, 1)
      data[:end_date] = Time.zone.local(2019, 10, 1)
      form.application_work_experiences.create(data)
    end
  end

  let(:application_form_with_break) do
    build_stubbed(
      :application_form,
      application_work_history_breaks: [
        build_stubbed(
          :application_work_history_break,
          start_date: february2019,
          end_date: april2019,
          reason: 'WE WERE ON A BREAK!',
        ),
      ],
      application_work_experiences: [
        build_stubbed(:application_work_experience, start_date: Time.zone.local(2014, 10, 1), end_date: Time.zone.local(2014, 11, 1)),
        build_stubbed(:application_work_experience, start_date: Time.zone.local(2019, 8, 1), end_date: Time.zone.local(2019, 9, 1)),
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
        build_stubbed(:application_work_experience, start_date: Time.zone.local(2014, 10, 1), end_date: Time.zone.local(2014, 11, 1)),
        build_stubbed(:application_work_experience, start_date: Time.zone.local(2019, 8, 1), end_date: Time.zone.local(2019, 9, 1)),
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
        expect(result.text).to include('Delete entry for break between Feb 2019 and Apr 2019')
        expect(result.text).to include('Change entry for break between Feb 2019 and Apr 2019')
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

        expect(result.text).not_to include('Change entry for experience between Aug 2019 and Oct 2019')
        expect(result.text).not_to include('Delete entry for experience between Aug 2019 and Oct 2019')
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
