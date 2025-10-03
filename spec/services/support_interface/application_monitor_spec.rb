require 'rails_helper'

RSpec.describe SupportInterface::ApplicationMonitor do
  let(:open_course) { create(:course, :open, :with_course_options) }
  let(:closed_course) { create(:course, application_status: 'closed') }

  let(:visible_course) { create(:course, :open, :with_course_options) }
  let(:hidden_course) { create(:course, :open, exposed_in_find: false) }

  describe '#applications_with_mismatched_recruitment_cycle_years' do
    let(:application_form) { create(:application_form) }
    let(:next_year_course) do
      create(
        :course,
        :open,
        :with_course_options,
        recruitment_cycle_year: application_form.recruitment_cycle_year + 1,
      )
    end
    let(:same_year_course) do
      create(
        :course,
        :open,
        :with_course_options,
        recruitment_cycle_year: application_form.recruitment_cycle_year,
      )
    end

    it 'does not return form if the choice is deferred' do
      create(:application_choice, application_form:, offer_deferred_at: Time.zone.now, course: next_year_course)
      expect(described_class.new.applications_with_mismatched_recruitment_cycle_years).to eq []
    end

    it 'does not include form if the choice is for the current year' do
      create(:application_choice, application_form:, offer_deferred_at: nil, course: same_year_course)
      expect(described_class.new.applications_with_mismatched_recruitment_cycle_years).to eq []
    end

    it 'returns form if the choice is for a different year and not deferred' do
      create(:application_choice, application_form:, offer_deferred_at: nil, course: next_year_course)
      expect(described_class.new.applications_with_mismatched_recruitment_cycle_years).to include application_form
    end
  end

  describe '#applications_to_closed_courses' do
    it 'returns applications to courses that have been closed' do
      closed_course_option                  = create(:course_option, course: closed_course)
      application_to_closed_course          = create(:application_choice, course_option: closed_course_option, status: 'awaiting_provider_decision')
      # application_to_open_course
      create(:application_choice, course: open_course, status: 'awaiting_provider_decision')
      # rejected_application_to_closed_course
      create(:application_choice, course: closed_course, status: 'rejected')

      applications = described_class.new.applications_to_closed_courses

      expect(applications).to contain_exactly(application_to_closed_course.application_form)
    end
  end

  describe '#applications_to_hidden_courses' do
    it 'returns applications to courses that have been removed from Find' do
      hidden_course_option = create(:course_option, course: hidden_course)
      application_to_hidden_course = create(:application_choice, course_option: hidden_course_option, status: 'awaiting_provider_decision')
      # application_to_visible_course
      create(:application_choice, course: visible_course, status: 'awaiting_provider_decision')

      applications = described_class.new.applications_to_hidden_courses

      expect(applications).to contain_exactly(application_to_hidden_course.application_form)
    end
  end

  describe '#applications_to_courses_with_sites_without_vacancies' do
    it 'returns applications to courses that have marked as no longer having vacancies' do
      with_vacancies = create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, vacancy_status: 'vacancies'))
      without_vacancies = create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, vacancy_status: 'no_vacancies'))

      applications = described_class.new.applications_to_courses_with_sites_without_vacancies

      expect(applications.map(&:id)).not_to include(with_vacancies.application_form_id)
      expect(applications.map(&:id)).to include(without_vacancies.application_form_id)
    end
  end

  describe '#applications_to_removed_sites' do
    it 'returns applications to sites that have been removed from Find' do
      with_okay_site = create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, site_still_valid: true))
      with_removed_site = create(:application_choice, status: 'awaiting_provider_decision', course_option: create(:course_option, site_still_valid: false))

      applications = described_class.new.applications_to_removed_sites

      expect(applications.map(&:id)).not_to include(with_okay_site.application_form_id)
      expect(applications.map(&:id)).to include(with_removed_site.application_form_id)
    end
  end
end
