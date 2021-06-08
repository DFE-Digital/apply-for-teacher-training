require 'rails_helper'

RSpec.describe RestructuredWorkHistory::JobComponent do
  it 'renders the component with the correct values' do
    work_experience = build_stubbed(
      :application_work_experience,
      role: 'Teaching Assistant',
      organisation: 'Mallowpond Secondary College',
      start_date: Time.zone.local(2018, 12, 1),
      end_date: Time.zone.local(2019, 12, 1),
      relevant_skills: true,
      commitment: :full_time,
    )

    result = render_inline(described_class.new(work_experience: work_experience))

    expect(result.text).to include('Teaching Assistant')
    expect(result.text).to include('Mallowpond Secondary College')
    expect(result.text).to include('Dec 2018 to Dec 2019')
    expect(result.text).to include('This role used skills relevant to teaching')
    expect(result.css('a').first.text).to include('Change')
    expect(result.css('a').last.text).to include('Delete')
  end

  context 'when the role is part time' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed(
        :application_work_experience,
        role: 'Teaching Assistant',
        organisation: 'Mallowpond Secondary College',
        start_date: Time.zone.local(2018, 12, 1),
        end_date: Time.zone.local(2019, 12, 1),
        relevant_skills: true,
        commitment: :part_time,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).to include('Teaching Assistant (Part time)')
    end
  end

  context 'when the role does not have relevant skills' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed(
        :application_work_experience,
        role: 'Teaching Assistant',
        organisation: 'Mallowpond Secondary College',
        start_date: Time.zone.local(2018, 12, 1),
        end_date: Time.zone.local(2019, 12, 1),
        relevant_skills: false,
        commitment: :full_time,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).not_to include('This role used skills relevant to teaching')
    end
  end

  context 'when the candidate is currently employed in the role' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed(
        :application_work_experience,
        role: 'Teaching Assistant',
        organisation: 'Mallowpond Secondary College',
        start_date: Time.zone.local(2018, 12, 1),
        currently_working: true,
        relevant_skills: true,
        commitment: :full_time,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).to include('Dec 2018 to Present')
    end
  end

  context 'when the candidate does not know start & end dates' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed(
        :application_work_experience,
        role: 'Teaching Assistant',
        organisation: 'Mallowpond Secondary College',
        start_date: Time.zone.local(2018, 12, 1),
        start_date_unknown: true,
        end_date: Time.zone.local(2019, 12, 1),
        end_date_unknown: true,
        relevant_skills: true,
        commitment: :full_time,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).to include('Dec 2018 (estimate) to Dec 2019 (estimate)')
    end
  end
end
