require 'rails_helper'

RSpec.describe ApplicationForm do
  describe 'auditing' do
    it 'records an audit entry when creating a new ApplicationForm' do
      application_form = create :application_form
      expect(application_form.audits.count).to eq 1
    end

    it 'can view audit records for ApplicationForm and its associated ApplicationChoices' do
      application_form = create :completed_application_form
      expect(application_form.own_and_associated_audits.count).to eq 6
      application_form.application_choices.first.update!(personal_statement: 'hello again')
      expect(application_form.own_and_associated_audits.count).to eq 7
    end
  end

  describe '#update' do
    it 'updates the application_choices updated_at as well' do
      original_time = Time.now - 1.day
      application_form = create(:application_form)
      application_choices = create_list(
        :application_choice,
        2,
        application_form: application_form,
        updated_at: original_time,
      )

      application_form.update!(first_name: 'Something else')
      application_choices.each(&:reload)

      expect(application_choices.map(&:updated_at)).not_to include(original_time)
    end
  end

  describe '#science_gcse_needed?' do
    before { FeatureFlag.activate('conditional_science_gcse') }

    context 'when a candidate has no course choices' do
      it 'returns false' do
        application_form = build_stubbed(:application_form)

        expect(application_form.science_gcse_needed?).to eq(false)
      end
    end

    context 'when a candidate has a course choice that is primary' do
      it 'returns true' do
        application_form = application_form_with_course_option_for_provider_with(level: 'primary')

        expect(application_form.science_gcse_needed?).to eq(true)
      end
    end

    context 'when a candidate has a course choice that is secondary' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'secondary')

        expect(application_form.science_gcse_needed?).to eq(false)
      end
    end

    context 'when a candidate has a course choice that is further education' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'further_education')

        expect(application_form.science_gcse_needed?).to eq(false)
      end
    end

    def application_form_with_course_option_for_provider_with(level:)
      provider = build(:provider)
      course = create(:course, level: level, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_form = create(:application_form)

      create(
        :application_choice,
        application_form: application_form,
        course_option: course_option,
      )

      application_form
    end
  end
end
