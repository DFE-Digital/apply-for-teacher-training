require 'rails_helper'

RSpec.describe RestructuredWorkHistory::JobComponent do
  def build_stubbed_work_experience(attrs = {})
    build_stubbed(
      :application_work_experience,
      {
        role: 'Teaching Assistant',
        organisation: 'Mallowpond Secondary College',
        start_date: Time.zone.local(2018, 12, 1),
        end_date: Time.zone.local(2019, 12, 1),
        relevant_skills: true,
        commitment: :full_time,
      }.merge(attrs),
    )
  end

  it 'renders the component with the correct values' do
    work_experience = build_stubbed_work_experience

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
      work_experience = build_stubbed_work_experience(
        commitment: :part_time,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).to include('Teaching Assistant (Part time)')
    end
  end

  context 'when the role does not have relevant skills' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed_work_experience(
        relevant_skills: false,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).not_to include('This role used skills relevant to teaching')
    end
  end

  context 'when the candidate has not answered the relevant skills question' do
    it 'renders the component with a call to action and link to edit form' do
      work_experience = build_stubbed_work_experience(
        relevant_skills: nil,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      relevant_skills_link = result.css("a[href='/candidate/application/restructured-work-history/edit/#{work_experience.id}']").first
      expect(relevant_skills_link).to be_present
      expect(relevant_skills_link.text).to include('Select if this role used skills relevant to teaching')
    end

    it 'does not render the call to action and link to edit form when not editable' do
      work_experience = build_stubbed_work_experience

      result = render_inline(described_class.new(work_experience: work_experience, editable: false))

      relevant_skills_link = result.css("a[href='/candidate/application/restructured-work-history/edit/#{work_experience.id}']").first
      expect(relevant_skills_link).not_to be_present
    end
  end

  context 'when the candidate is currently employed in the role' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed_work_experience(
        currently_working: true,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).to include('Dec 2018 to Present')
    end
  end

  context 'when the candidate does not know start & end dates' do
    it 'renders the component with the correct values' do
      work_experience = build_stubbed_work_experience(
        start_date_unknown: true,
        end_date_unknown: true,
      )

      result = render_inline(described_class.new(work_experience: work_experience))

      expect(result.text).to include('Dec 2018 (estimate) to Dec 2019 (estimate)')
    end
  end
end
