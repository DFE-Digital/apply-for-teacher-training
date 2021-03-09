require 'rails_helper'

RSpec.describe FilterApplicationChoicesForProviders do
  describe '.call' do
    let(:application_choices) do
      create_list(:application_choice, 2, :with_completed_application_form)
      ApplicationChoice.annotate_with_courses.all
    end

    it 'filters by candidate reference' do
      result = described_class.call(application_choices: application_choices, filters: { candidate_name: " #{application_choices.first.application_form.support_reference}" })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by partial candidate reference' do
      partial_reference = application_choices.first.application_form.support_reference[0...3]
      result = described_class.call(application_choices: application_choices, filters: { candidate_name: partial_reference })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by candidate name' do
      result = described_class.call(application_choices: application_choices, filters: { candidate_name: application_choices.last.application_form.last_name })

      expect(result).to eq([application_choices.last])
    end

    it 'filters by recruitment cycle year' do
      course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 1999))
      application_choices.last.update(course_option: course_option)

      result = described_class.call(application_choices: application_choices.joins(:course), filters: { recruitment_cycle_year: '1999' })

      expect(result).to eq([application_choices.last])
    end

    it 'uses the updated course details when filtering by recruitment cycle year' do
      course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 1999))
      application_choices.last.update(offered_course_option_id: course_option.id)

      result = described_class.call(application_choices: application_choices.joins(:course), filters: { recruitment_cycle_year: '1999' })

      expect(result).to eq([application_choices.last])
    end

    it 'filters by status' do
      application_choices.first.update(status: 'rejected', rejected_at: Time.zone.now)
      application_choices.last.update(status: 'withdrawn', withdrawn_at: Time.zone.now)
      result = described_class.call(application_choices: application_choices, filters: { status: 'rejected' })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by provider' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_choices.first.update(course_option: course_option)
      result = described_class.call(application_choices: application_choices.joins(:course), filters: { provider: provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'uses the updated course details when filtering by provider' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_choices.first.update(offered_course_option_id: course_option.id)
      result = described_class.call(application_choices: application_choices.joins(:course), filters: { provider: provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by accredited provider' do
      course_option = create(:course_option, course: create(:course, accredited_provider_id: 2121))
      application_choices.first.update(course_option: course_option)
      result = described_class.call(application_choices: application_choices.joins(:course), filters: { accredited_provider: '2121' })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by provider location' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_choices.last.update(course_option: course_option)
      result = described_class.call(application_choices: application_choices.joins(:course, :site), filters: { provider_location: site.id })

      expect(result).to eq([application_choices.last])
    end

    it 'uses the updated course details when filtering by provider location' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_choices.last.update(offered_course_option_id: course_option.id)
      result = described_class.call(application_choices: application_choices.joins(:course, :site), filters: { provider_location: site.id })

      expect(result).to eq([application_choices.last])
    end
  end
end
