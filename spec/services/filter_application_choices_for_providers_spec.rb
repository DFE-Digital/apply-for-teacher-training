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
          application_choices:,
          filters: { candidate_name: " #{application_choices.first.id}" },
        )
      end

      it { is_expected.to eq [application_choices.first] }
    end

    it 'filters by candidate name' do
      application_choice = application_choices.last
      result = described_class.call(application_choices:, filters: { candidate_name: application_choice.application_form.last_name })

      expect(result).to eq([application_choice])
    end

    it 'filters by candidate name with superfluous spaces' do
      application_choice = application_choices.last
      result = described_class.call(application_choices:, filters: { candidate_name: " #{application_choice.application_form.last_name} " })

      expect(result).to eq([application_choice])
    end

    it 'filters by recruitment cycle year' do
      application_choices.last.course.update(recruitment_cycle_year: 2021)

      result = described_class.call(application_choices:, filters: { recruitment_cycle_year: '2021' })

      expect(result).to eq([application_choices.last])
    end

    it 'uses the updated course details when filtering by recruitment cycle year' do
      course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 2021))
      application_choices.last.update(current_course_option_id: course_option.id)

      result = described_class.call(application_choices:, filters: { recruitment_cycle_year: '2021' })

      expect(result).to eq([application_choices.last])
    end

    context 'when filtering by status' do
      it 'filters by selected status' do
        application_choices.first.update(status: 'rejected', rejected_at: Time.zone.now)
        application_choices.last.update(status: 'withdrawn', withdrawn_at: Time.zone.now)
        result = described_class.call(application_choices:, filters: { status: 'rejected' })

        expect(result).to eq([application_choices.first])
      end

      it 'includes inactive when received is selected' do
        application_choices.first.update(status: :awaiting_provider_decision)
        application_choices.last.update(status: :inactive)
        result = described_class.call(application_choices:, filters: { status: ['awaiting_provider_decision'] })

        expect(result).to contain_exactly(application_choices.first, application_choices.last)
      end
    end

    it 'filters by provider' do
      provider = create(:provider)
      application_choices.first.course.update(provider:)
      result = described_class.call(application_choices:, filters: { provider: provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by study mode' do
      application_choices.first.course_option.update(study_mode: 'part_time')
      result = described_class.call(application_choices:, filters: { study_mode: 'part_time' })

      expect(result).to eq([application_choices.first])
    end

    it 'uses the updated course details when filtering by provider' do
      provider = create(:provider)
      course = create(:course, provider:)
      site = create(:site, provider:)
      course_option = create(:course_option, course:, site:)
      application_choices.first.update(current_course_option_id: course_option.id)
      result = described_class.call(application_choices:, filters: { provider: provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by accredited provider' do
      accredited_provider = create(:provider)
      application_choices.first.course.update(accredited_provider:)
      result = described_class.call(application_choices:, filters: { accredited_provider: accredited_provider.id })

      expect(result).to eq([application_choices.first])
    end

    it 'filters by provider location' do
      provider = create(:provider)
      course = create(:course, provider:)
      site = create(:site, provider:)
      application_choices.last.course_option.update(course:, site:)
      result = described_class.call(application_choices:, filters: { provider_location: ["#{site.provider_id}_#{site.name}_#{site.code}"] })

      expect(result).to eq([application_choices.last])
    end

    it 'filters by multiple provider locations' do
      provider = create(:provider)
      course = create(:course, provider:)
      first_site = create(:site, provider:, name: "Falafel's Finest")
      second_site  = create(:site, provider:, name: "Tabbouleh's Tightest")

      first_choice = application_choices.first
      second_choice = application_choices.second

      first_choice.course_option.update(course:, site: first_site)
      second_choice.course_option.update(course:, site: second_site)
      result = described_class.call(application_choices:, filters: { provider_location: ["#{first_site.provider_id}_#{first_site.name}_#{first_site.code}", "#{second_site.provider_id}_#{second_site.name}_#{second_site.code}"] })

      expect(result.pluck(:id)).to contain_exactly(first_choice.id, second_choice.id)
    end

    it 'filters by course subjects' do
      subject = create(:subject)
      application_choices.last.course.subjects << subject
      result = described_class.call(application_choices:, filters: { subject: [subject.id] })

      expect(result).to eq([application_choices.last])
    end

    it 'uses the updated course details when filtering by provider location' do
      provider = create(:provider)
      course = create(:course, provider:)
      site = create(:site, provider:)
      course_option = create(:course_option, course:, site:)
      application_choices.last.update(current_course_option_id: course_option.id)
      result = described_class.call(application_choices:, filters: { provider_location: ["#{site.provider_id}_#{site.name}_#{site.code}"] })

      expect(result).to eq([application_choices.last])
    end

    context 'filter by invites' do
      let(:application_form) { ApplicationForm.find_by(support_reference: 'XY6789') }
      let(:candidate) { application_form.candidate }
      let(:application_choice) { application_choices.find_by(application_form:) }
      let(:course) { application_choice.current_course }

      before { application_choices }

      it 'returns invited candidate' do
        create(:pool_invite, :sent_to_candidate, candidate:, course:, provider: course.provider)

        result = described_class.call(application_choices:, filters: { invited_only: ['invited_only'] })
        expect(result).to eq([application_choice])
      end

      it 'returns nothing when invite is not within years visible to providers' do
        recruitment_cycle_year = RecruitmentCycleTimetable.years_visible_to_providers.min - 1
        create(:pool_invite, :sent_to_candidate, candidate:, course:, provider: course.provider, recruitment_cycle_year:)

        result = described_class.call(application_choices:, filters: { invited_only: ['invited_only'] })
        expect(result).to eq([])
      end

      it 'when candidate has been invited to same provider, different course, returns invited candidate' do
        course_for_invite = create(:course, provider: course.provider)
        create(:pool_invite, :sent_to_candidate, candidate:, course: course_for_invite, provider: course_for_invite.provider)

        result = described_class.call(application_choices:, filters: { invited_only: ['invited_only'] })
        expect(result).to eq([application_choice])
      end
    end
  end
end
