require 'rails_helper'

RSpec.describe FilterApplicationChoicesForProviders do
  describe '.call' do
    let(:application_choices) do
      create(
        :application_choice,
        application_form: create(
          :completed_application_form,
          first_name: 'Bob',
          last_name: 'Roberts',
          support_reference: 'AB1234',
        ),
      )
      create(
        :application_choice,
        application_form: create(
          :completed_application_form,
          first_name: 'Alice',
          last_name: 'Alison',
          support_reference: 'XY6789',
        ),
      )
      ApplicationChoice.all
    end

    describe 'filtering by application choice id' do
      subject do
        described_class.call(
          application_choices: application_choices,
          filters: { candidate_name: " #{application_choices.first.id}" },
        )
      end

      it { is_expected.to eq [application_choices.first] }
    end

    it 'filters by candidate name' do
      application_choice = application_choices.last
      result = described_class.call(application_choices: application_choices, filters: { candidate_name: application_choice.application_form.last_name })

      expect(result).to eq([application_choice])
    end

    it 'filters by candidate name with superfluous spaces' do
      application_choice = application_choices.last
      result = described_class.call(application_choices: application_choices, filters: { candidate_name: " #{application_choice.application_form.last_name} " })

      expect(result).to eq([application_choice])
    end

    it 'filters by recruitment cycle year' do
      application_choices.last.course.update(recruitment_cycle_year: 1999)

      result = described_class.call(application_choices: application_choices, filters: { recruitment_cycle_year: '1999' })

      expect(result).to eq([application_choices.last])
    end

    it 'uses the updated course details when filtering by recruitment cycle year' do
      course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 1999))
      application_choices.last.update(current_course_option_id: course_option.id)

      result = described_class.call(application_choices: application_choices, filters: { recruitment_cycle_year: '1999' })

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
      application_choices.first.course.update(provider: provider)
      result = described_class.call(application_choices: application_choices, filters: { provider: provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by study mode' do
      application_choices.first.course_option.update(study_mode: 'part_time')
      result = described_class.call(application_choices: application_choices, filters: { study_mode: 'part_time' })

      expect(result).to eq([application_choices.first])
    end

    it 'uses the updated course details when filtering by provider' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_choices.first.update(current_course_option_id: course_option.id)
      result = described_class.call(application_choices: application_choices, filters: { provider: provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by accredited provider' do
      accredited_provider = create(:provider)
      application_choices.first.course.update(accredited_provider: accredited_provider)
      result = described_class.call(application_choices: application_choices, filters: { accredited_provider: accredited_provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by provider location' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      application_choices.last.course_option.update(course: course, site: site)
      result = described_class.call(application_choices: application_choices, filters: { provider_location: ["#{site.name}_#{site.code}"] })

      expect(result).to eq([application_choices.last])
    end

    it 'filters by course subjects' do
      subject = create(:subject)
      application_choices.last.course.subjects << subject
      result = described_class.call(application_choices: application_choices, filters: { subject: [subject.id] })

      expect(result).to eq([application_choices.last])
    end

    it 'uses the updated course details when filtering by provider location' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_choices.last.update(current_course_option_id: course_option.id)
      result = described_class.call(application_choices: application_choices, filters: { provider_location: ["#{site.name}_#{site.code}"] })

      expect(result).to eq([application_choices.last])
    end
  end
end
