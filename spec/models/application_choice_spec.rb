require 'rails_helper'

RSpec.describe ApplicationChoice, type: :model do
  describe '#create' do
    it 'starts in the "unsubmitted" status' do
      course_option = create(:course_option)
      application_choice = ApplicationChoice.create!(
        application_form: create(:application_form),
        course_option: course_option,
      )

      expect(application_choice).to be_unsubmitted
    end

    it 'allows a different status to be set' do
      course_option = create(:course_option)
      application_choice = ApplicationChoice.create!(
        status: 'application_complete',
        application_form: create(:application_form),
        course_option: course_option,
      )

      expect(application_choice).to be_application_complete
    end
  end

  describe 'auditing', with_audited: true do
    it 'creates audit entries' do
      application_choice = create :application_choice, status: 'unsubmitted'
      expect(application_choice.audits.count).to eq 1
      application_choice.update!(status: 'awaiting_references')
      expect(application_choice.audits.count).to eq 2
    end

    it 'creates an associated object in each audit record' do
      application_choice = create :application_choice
      expect(application_choice.audits.last.associated).to eq application_choice.application_form
    end

    it 'audit record can be attributed to a candidate' do
      candidate = create :candidate
      application_choice = Audited.audit_class.as_user(candidate) do
        create :application_choice
      end
      expect(application_choice.audits.last.user).to eq candidate
    end
  end

  describe '#course_full?' do
    context 'with 3 options all full' do
      it 'returns true' do
        course = create(:course)
        create_list(:course_option, 3, vacancy_status: :no_vacancies, course: course)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.course_full?).to be true
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns false' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.course_full?).to be false
      end
    end
  end

  describe '#site_full?' do
    context 'with 3 options all full' do
      it 'returns true' do
        course = create(:course)
        create_list(:course_option, 3, vacancy_status: :no_vacancies, course: course)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.site_full?).to be true
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns true' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.site_full?).to be true
      end
    end

    context 'with 2 options for same site only 1 full' do
      it 'returns true' do
        course = create(:course)
        site = create(:site, provider: course.provider)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course, site: site, study_mode: 'full_time')
        create(:course_option, vacancy_status: :vacancies, course: course, site: site, study_mode: 'part_time')
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.site_full?).to be false
      end
    end
  end

  describe '#course_study_mode_full?' do
    context 'with option that has vacancies' do
      it 'returns false' do
        course = create(:course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.study_mode_full?).to be false
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns true' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.study_mode_full?).to be true
      end
    end

    context 'with 2 options for same site only 1 full' do
      it 'returns true' do
        course = create(:course)
        site = create(:site, provider: course.provider)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course, site: site, study_mode: 'full_time')
        create(:course_option, vacancy_status: :vacancies, course: course, site: site, study_mode: 'part_time')
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.study_mode_full?).to be true
      end
    end
  end

  describe 'offer_withdrawn scope' do
    it 'returns offer withdrawn application choices' do
      create(:application_choice, status: 'rejected', offer_withdrawn_at: nil)
      offer_withdraw_application_choice = create(:application_choice, status: 'rejected', offer_withdrawn_at: 2.days.ago)
      expect(described_class.offer_withdrawn.count).to eq 1
      expect(described_class.offer_withdrawn).to eq [offer_withdraw_application_choice]
    end
  end
end
