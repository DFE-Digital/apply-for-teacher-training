require 'rails_helper'

RSpec.describe ApplicationChoice, type: :model do
  describe '#refresh_api_response_cache' do
    it 'updates last_public_update_at to the last time the application choice changed in the API' do
      choice = create(:application_choice, :with_rejection)

      expect {
        choice.update(rejection_reason: 'New rejection reason')
      }.to(change { choice.last_public_update_at })
    end

    it 'handles destroyed records' do
      choice = create(:application_choice, :with_rejection)

      expect { choice.destroy }.not_to raise_exception
    end

    # TODO: until we change application_choice.updated_at for application_choice.last_public_update_at
    # in the api response the cache will ALWAYS be invalid and we'll always have updated_at in the response.
    # this state of affairs will not exist for long
    #
    # it 'does not change last_public_update_at when an update would not change the application in the API' do
    #   choice = create(:application_choice, :awaiting_provider_decision)
    #
    #   expect {
    #     choice.update(offer_deferred_at: Time.zone.now)
    #   }.not_to(change { choice.last_public_update_at })
    # end
  end

  describe 'auditing', with_audited: true do
    it 'creates audit entries' do
      application_choice = create :application_choice, status: 'unsubmitted'
      expect(application_choice.audits.count).to eq 1
      application_choice.update!(status: 'awaiting_provider_decision')
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
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course.course_options.first)
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

  describe 'validations' do
    subject(:application_choice) { create(:application_choice) }

    it { is_expected.to validate_uniqueness_of(:course_option).scoped_to(:application_form_id) }
  end

  describe '#structured_rejection_reasons' do
    it 'are serialized and rehydrateable' do
      reasons = ReasonsForRejection.new(
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Used the wrong spoon for soup',
      )

      application_choice = create(:application_choice, :with_rejection)
      application_choice.update!(structured_rejection_reasons: reasons)

      rehydrated_reasons = ReasonsForRejection.new(application_choice.reload.structured_rejection_reasons)
      expect(rehydrated_reasons.candidate_behaviour_y_n).to eq('Yes')
      expect(rehydrated_reasons.candidate_behaviour_what_did_the_candidate_do).to eq(%w[other])
      expect(rehydrated_reasons.candidate_behaviour_other).to eq('Used the wrong spoon for soup')
    end
  end
end
