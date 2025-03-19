require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::PickCourseForm, type: :model do
  describe '#course_options' do
    let(:first_site) { build(:site) }
    let(:second_site) { build(:site) }
    let(:provider) { build(:provider, sites: [first_site, second_site]) }
    let(:course) { build(:course, :open, code: 'ABC', provider:) }

    it 'returns course options that have already been added to an application form' do
      course_option = build(:course_option, site: first_site, course:)
      application_choice = build(:application_choice, course_option:)
      application_form = create(:application_form, application_choices: [application_choice])

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options = described_class.new(form_data).course_options

      expect(course_options.length).to eq(1)
    end

    it 'does not return course options for courses not open on apply' do
      course = create(:course)
      create(:course_option, course: create(:course))
      application_form = create(:completed_application_form)

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options = described_class.new(form_data).course_options

      expect(course_options).to be_empty
    end
  end

  describe '#course_options_for_provider' do
    let(:first_site) { build(:site) }
    let(:second_site) { build(:site) }
    let(:provider) { build(:provider, sites: [first_site, second_site]) }
    let(:course) { build(:course, :open, code: 'ABC', provider:) }

    it 'returns course options that do and do not have vacancies' do
      course_option_with_vacancies = create(:course_option, site: first_site, course:)
      course_option_with_no_vacancies = create(:course_option, course:, site: second_site, vacancy_status: 'no_vacancies')
      application_form = create(:application_form)

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options_for_provider = described_class.new(form_data).course_options_for_provider(provider)

      expect(course_options_for_provider.length).to eq(2)
      expect(course_options_for_provider.map(&:course_option_id).sort).to eq([course_option_with_vacancies.id, course_option_with_no_vacancies.id].sort)
    end

    it 'returns only course options from current cycle' do
      course = create(:course, :open, code: 'ABC', provider:)
      same_course_from_another_cycle = create(:course, :open, code: course.code, provider:, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year, accredited_provider_id: provider.id)
      course_option_current_cycle = create(:course_option, site: first_site, course:)
      create(:course_option, :previous_year, site: second_site, course: same_course_from_another_cycle)
      application_form = create(:application_form)

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options_for_provider = described_class.new(form_data).course_options_for_provider(provider)

      expect(course_options_for_provider.length).to eq(1)
      expect(course_options_for_provider.first.course_option_id).to eq(course_option_current_cycle.id)
    end

    it 'only returns courses that are ratified by the same accredited_provider' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, :accepted, application_form:)

      provider1 = application_choice.provider
      site1 = create(:site, provider: provider1)
      course1 = create(:course, :open, provider: provider1, name: 'A', code: 'A123')

      provider2 = create(:provider)
      site2 = create(:site, provider: provider2)

      course2 = create(:course, :open, provider: provider2, accredited_provider: provider1, code: 'A123', name: 'B')

      course3 = create(:course, :open, code: 'A123')

      course_option_with_the_same_provider = create(:course_option, site: site1, course: course1)
      course_option_with_the_same_accrediting_provider = create(:course_option, site: site2, course: course2)
      create(:course_option, course: course3)

      form_data = {
        application_form_id: application_form.id,
        course_code: 'A123',
      }

      course_options_for_provider = described_class.new(form_data).course_options_for_provider(provider1)

      expect(course_options_for_provider.length).to eq(2)
      expect(course_options_for_provider.first.course_option_id).to eq course_option_with_the_same_provider.id
      expect(course_options_for_provider.second.course_option_id).to eq course_option_with_the_same_accrediting_provider.id
    end

    it 'returns course options that have already been added to an application form' do
      course_option = build(:course_option, site: first_site, course:)
      application_choice = build(:application_choice, course_option:)
      application_form = create(:application_form, application_choices: [application_choice])

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options_for_provider = described_class.new(form_data).course_options_for_provider(provider)

      expect(course_options_for_provider.size).to eq(1)
    end

    it 'returns course options for courses marked not_in_find' do
      application_form = build_stubbed(:completed_application_form)
      course_not_in_find = create(:course, :open, provider:, exposed_in_find: false)
      course_option = create(:course_option, course: course_not_in_find)

      form_data = {
        application_form_id: application_form.id,
        course_code: course_not_in_find.code,
      }

      expected_radio_option = SupportInterface::ApplicationForms::PickCourseForm::RadioOption.new(
        course_option_id: course_option.id,
        provider_name: course_option.provider.name,
        provider_code: course_option.provider.code,
        course_name: course_option.course.name,
        course_code: course_option.course.code,
        site_name: course_option.site.name,
        study_mode: course_option.study_mode.humanize,
      )

      course_options_for_provider = described_class.new(form_data).course_options_for_provider(provider)

      expect(course_options_for_provider).to eq([expected_radio_option])
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_option_id) }
    it { is_expected.to validate_presence_of(:application_form_id) }

    it 'checks that the course exists' do
      form = described_class.new(course_option_id: '123', course_code: 'ABC')
      expect(form.valid?(:save)).to be false
      expect(form.errors[:course_option_id]).to eq(['This course does not exist'])
    end
  end
end
