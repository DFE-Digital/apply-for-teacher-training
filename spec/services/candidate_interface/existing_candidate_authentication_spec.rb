require 'rails_helper'

RSpec.describe CandidateInterface::ExistingCandidateAuthentication do
  include CourseOptionHelpers

  describe '#execute' do
    context 'when the candidate has a course_from_find_id and the course has one site' do
      it 'adds a the course, resets the course_from_find_in to nil and returns sets candidate_has_new_course_added to true' do
        provider = create(:provider)
        course_option_for_provider(provider: provider)
        candidate = create(:candidate, course_from_find_id: provider.courses.first.id)
        course_options_id = provider.courses.first.course_options.first.id

        service = described_class.new(candidate: candidate)
        service.execute

        expect(service).to be_candidate_has_new_course_added
        expect(service).not_to be_candidate_should_choose_site
        expect(service).not_to be_candidate_does_not_have_a_course_from_find_id
        expect(candidate.course_from_find_id).to eq(nil)
        expect(candidate.current_application.application_choices.first.course_option_id).to eq(course_options_id)
      end
    end

    context 'when the candidate has a course_from_find_id  and the course has multiple sites' do
      it 'sets the course_from_find_id to nil and sets candidate_should_choose_site to true' do
        course = create(:course)
        create_two_course_options_for_course(course: course)
        candidate = create(:candidate, course_from_find_id: course.id)

        service = described_class.new(candidate: candidate)
        service.execute

        expect(service).to be_candidate_should_choose_site
        expect(service).not_to be_candidate_has_new_course_added
        expect(service).not_to be_candidate_does_not_have_a_course_from_find_id
        expect(candidate.course_from_find_id).to eq(nil)
        expect(candidate.current_application.application_choices).not_to be_present
      end
    end

    context 'when the user does not have a course_from_find_id' do
      it 'sets candidate_does_not_have_course_from_find_id' do
        create(:course, open_on_apply: true)
        candidate = create(:candidate, course_from_find_id: nil)

        service = described_class.new(candidate: candidate)
        service.execute

        expect(service).to be_candidate_does_not_have_a_course_from_find_id
        expect(service).not_to be_candidate_has_new_course_added
        expect(service).not_to be_candidate_should_choose_site
      end
    end
  end

private

  def create_two_course_options_for_course(course:)
    site = create(:site, provider: course.provider)
    site2 = create(:site, provider: course.provider)
    create(:course_option, site: site, course: course, vacancy_status: 'B')
    create(:course_option, site: site2, course: course, vacancy_status: 'B')
  end
end
