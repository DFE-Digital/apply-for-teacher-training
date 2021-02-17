require 'rails_helper'

RSpec.describe CandidateInterface::WorkHistoryReviewComponent do
  let(:february2019) { Time.zone.local(2019, 2, 1) }
  let(:april2019) { Time.zone.local(2019, 4, 1) }
  let(:data) do
    {
      role: 'Teaching Assistant',
      organisation: Faker::Educator.secondary_school,
      details: Faker::Lorem.paragraph_by_chars(number: 300),
      commitment: %w[full_time part_time].sample,
      working_with_children: [true, true, true, false].sample,
    }
  end

  context 'when there is not a break in the work history' do
    let(:application_form) do
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

    context 'when jobs are editable' do
      it 'renders component with correct structure' do
        result = render_inline(described_class.new(application_form: application_form))

        application_form.application_work_experiences.each do |work|
          expect(result.text).to include(work.role)
          expect(result.text).to include(work.start_date.to_s(:month_and_year))
          expect(result.text).to include(work.working_with_children ? 'Yes' : 'No')
        end
      end

      it 'renders correct text for "Change" links in each attribute row' do
        result = render_inline(described_class.new(application_form: application_form))

        change_job_title = result.css('.govuk-summary-list__actions')[0].text.strip
        change_employer = result.css('.govuk-summary-list__actions')[1].text.strip
        change_type = result.css('.govuk-summary-list__actions')[2].text.strip
        change_dates = result.css('.govuk-summary-list__actions')[3].text.strip
        change_description = result.css('.govuk-summary-list__actions')[4].text.strip
        change_work_with_children = result.css('.govuk-summary-list__actions')[5].text.strip

        expect(change_job_title).to eq(
          'Change job title for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_employer).to eq(
          'Change employer for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_type).to eq(
          'Change working pattern for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_dates).to eq(
          'Change dates for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_description).to eq(
          'Change skills and experience for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_work_with_children).to eq(
          'Change if this job involved working in a school or with children for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
      end

      it 'appends dates to "Change" links if same role at same organisation' do
        result = render_inline(described_class.new(application_form: application_form))

        change_job_title_for_same1 = result.css('.govuk-summary-list__actions')[0].text.strip
        change_job_title_for_unique = result.css('.govuk-summary-list__actions')[6].text.strip
        change_job_title_for_same2 = result.css('.govuk-summary-list__actions')[12].text.strip

        expect(change_job_title_for_same1).to eq(
          'Change job title for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_job_title_for_unique).to eq(
          'Change job title for Teaching Assistant, Theo School',
        )
        expect(change_job_title_for_same2).to eq(
          'Change job title for Teaching Assistant, Vararu School, August 2019 to October 2019',
        )
      end
    end

    context 'when jobs are not editable' do
      it 'renders component without an edit link' do
        result = render_inline(described_class.new(application_form: application_form, editable: false))

        expect(result.css('.app-summary-list__actions').text).not_to include('Change')
        expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.work_history.delete_entry.action'))
      end
    end
  end

  context 'when there are breaks in the work history' do
    let(:application_form) do
      create(:application_form) do |form|
        data[:start_date] = Time.zone.local(2019, 8, 1)
        data[:end_date] = Time.zone.local(2019, 9, 1)
        form.application_work_experiences.create(data)

        form.work_history_breaks = 'WE WERE ON A BREAK!'
      end
    end

    around do |example|
      Timecop.freeze(Time.zone.local(2019, 10, 1)) do
        example.run
      end
    end

    context 'There are existing individual breaks and editable' do
      it 'renders component with change and delete links' do
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)
        breaks = [break1]

        result = render(breaks: breaks)

        expect(result.text).to include('Delete entry for break between February 2019 and April 2019')
        expect(result.text).to include('Change description for break between February 2019 and April 2019')
        expect(result.text).to include('Change dates for break between February 2019 and April 2019')
      end
    end

    context 'There are existing individual breaks and not editable' do
      it 'renders component without change and delete links' do
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019)
        breaks = [break1]

        result = render(breaks: breaks, editable: false)

        expect(result.text).not_to include('Delete entry for break between February 2019 and April 2019')
        expect(result.text).not_to include('Change description for break between February 2019 and April 2019')
        expect(result.text).not_to include('Change dates for break between February 2019 and April 2019')
      end
    end
  end

  context 'when no work experience' do
    let(:application_form) do
      create(:application_form, work_history_explanation: 'I no work.')
    end

    context 'when no work experience explanantion is editable' do
      it 'renders component asking for an explanation' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__key').text).to include('Explanation of why you’ve been out of the workplace')
        expect(result.css('.govuk-summary-list__value').to_html).to include('I no work.')
        expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
          Rails.application.routes.url_helpers.candidate_interface_work_history_explanation_path,
        )
        expect(result.css('.govuk-summary-list__actions').text).to include('Change explanation of why you’ve been out of the workplace')
      end
    end

    context 'when no work experience explanantion is not editable' do
      it 'renders component asking for an explanation' do
        result = render_inline(described_class.new(application_form: application_form, editable: false))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change explanation')
      end
    end
  end

  def render(explanation: nil, breaks: [], editable: true)
    data[:start_date] = Time.zone.local(2019, 8, 1)
    data[:end_date] = Time.zone.local(2019, 9, 1)

    application_form = build_stubbed(
      :application_form,
      work_history_breaks: explanation,
      application_work_history_breaks: breaks,
      application_work_experiences: [build_stubbed(:application_work_experience, attributes: data)],
    )

    render_inline(described_class.new(application_form: application_form, editable: editable))
  end
end
