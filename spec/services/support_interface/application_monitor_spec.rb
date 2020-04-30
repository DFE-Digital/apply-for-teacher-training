require 'rails_helper'

RSpec.describe SupportInterface::ApplicationMonitor do
  describe '#applications_to_disabled_courses' do
    it 'returns applications to courses that have been disabled' do
      application_to_open_course = create(:application_choice, status: 'awaiting_provider_decision')
      application_to_open_course.course.update! open_on_apply: true
      application_to_closed_course = create(:application_choice, status: 'awaiting_provider_decision')
      application_to_closed_course.course.update! open_on_apply: false
      rejected_application_to_closed_course = create(:application_choice, status: 'rejected')
      rejected_application_to_closed_course.course.update! open_on_apply: false

      applications = described_class.new.applications_to_disabled_courses

      expect(applications.map(&:id)).not_to include(application_to_open_course.application_form_id)
      expect(applications.map(&:id)).not_to include(rejected_application_to_closed_course.application_form_id)
      expect(applications.map(&:id)).to include(application_to_closed_course.application_form_id)
    end
  end

  describe '#applications_to_hidden_courses' do
    it 'returns applications to courses that have been removed from Find' do
      application_to_visible_course = create(:application_choice, status: 'awaiting_provider_decision')
      application_to_visible_course.course.update! open_on_apply: true, exposed_in_find: true
      application_to_hidden_course = create(:application_choice, status: 'awaiting_provider_decision')
      application_to_hidden_course.course.update! open_on_apply: true, exposed_in_find: false

      applications = described_class.new.applications_to_hidden_courses

      expect(applications.map(&:id)).not_to include(application_to_visible_course.application_form_id)
      expect(applications.map(&:id)).to include(application_to_hidden_course.application_form_id)
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
