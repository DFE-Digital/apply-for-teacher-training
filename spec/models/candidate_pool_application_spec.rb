require 'rails_helper'

RSpec.describe CandidatePoolApplication do
  describe 'associations' do
    it { is_expected.to belong_to(:application_form) }
    it { is_expected.to belong_to(:candidate) }
  end

  describe '.filtered_application_forms' do
    it 'returns application_forms based on filters' do
      subject_candidate_form = create(:application_form, :completed)
      create(
        :candidate_pool_application,
        application_form: subject_candidate_form,
        candidate: subject_candidate_form.candidate,
        subject_ids: [1],
        course_funding_type_fee: true,
      )
      part_time_candidate_form = create(:application_form, :completed)
      create(
        :candidate_pool_application,
        application_form: part_time_candidate_form,
        candidate: part_time_candidate_form.candidate,
        subject_ids: [1],
        study_mode_part_time: true,
        course_funding_type_fee: false,
      )
      undergraduate_candidate_form = create(:application_form, :completed)
      create(
        :candidate_pool_application,
        application_form: undergraduate_candidate_form,
        candidate: undergraduate_candidate_form.candidate,
        subject_ids: [1],
        study_mode_part_time: true,
        course_type_undergraduate: true,
        course_funding_type_fee: false,
      )
      visa_sponsorship_candidate_form = create(:application_form, :completed)
      create(
        :candidate_pool_application,
        application_form: visa_sponsorship_candidate_form,
        candidate: visa_sponsorship_candidate_form.candidate,
        needs_visa: true,
        course_funding_type_fee: false,
      )

      filters = {}
      application_forms = described_class.filtered_application_forms(filters)

      expect(application_forms.ids).to contain_exactly(
        subject_candidate_form.id,
        part_time_candidate_form.id,
        undergraduate_candidate_form.id,
        visa_sponsorship_candidate_form.id,
      )

      filters = { subject_ids: ['1'] }
      application_forms = described_class.filtered_application_forms(filters)

      expect(application_forms.ids).to contain_exactly(
        subject_candidate_form.id,
        part_time_candidate_form.id,
        undergraduate_candidate_form.id,
      )

      filters = {
        subject_ids: ['1'],
        study_mode: ['part_time'],
      }
      application_forms = described_class.filtered_application_forms(filters)

      expect(application_forms.ids).to contain_exactly(
        part_time_candidate_form.id,
        undergraduate_candidate_form.id,
      )

      filters = {
        subject_ids: ['1'],
        study_mode: ['part_time'],
        course_type: ['undergraduate'],
      }
      application_forms = described_class.filtered_application_forms(filters)

      expect(application_forms.ids).to contain_exactly(
        undergraduate_candidate_form.id,
      )

      filters = {
        funding_type: ['fee'],
      }
      application_forms = described_class.filtered_application_forms(filters)

      expect(application_forms.ids).to contain_exactly(
        subject_candidate_form.id,
      )

      filters = {
        visa_sponsorship: ['required'],
      }
      application_forms = described_class.filtered_application_forms(filters)

      expect(application_forms.ids).to contain_exactly(
        visa_sponsorship_candidate_form.id,
      )

      provider_user = create(:provider_user, :with_two_providers)
      form_rejected_by_both_providers = create(:application_form)
      form_rejected_by_one_provider = create(:application_form)
      form_rejected_by_another_provider = create(:application_form)

      create(:candidate_pool_application, application_form: form_rejected_by_both_providers, rejected_provider_ids: provider_user.provider_ids)
      create(:candidate_pool_application, application_form: form_rejected_by_one_provider, rejected_provider_ids: [provider_user.providers.first.id])
      create(:candidate_pool_application, application_form: form_rejected_by_another_provider, rejected_provider_ids: [create(:provider).id])

      application_forms = described_class.filtered_application_forms({}, provider_user)

      expect(application_forms.ids).to include(form_rejected_by_one_provider.id)
      expect(application_forms.ids).to include(form_rejected_by_another_provider.id)
      expect(application_forms.ids).not_to include(form_rejected_by_both_providers.id)
    end
  end

  describe '.closed?' do
    context 'after apply deadline', time: after_apply_deadline do
      it 'returns true' do
        expect(described_class.closed?).to be(true)
      end
    end

    context 'before apply opens', time: before_apply_opens do
      it 'returns true' do
        expect(described_class.closed?).to be(true)
      end
    end

    context 'before candidate_pool opens', time: described_class.open_at - 1.day do
      it 'returns true' do
        expect(described_class.closed?).to be(true)
      end
    end

    context 'after candidate_pool opens', time: described_class.open_at + 1.day do
      it 'returns false' do
        expect(described_class.closed?).to be(false)
      end
    end
  end

  describe '.open_at' do
    it 'returns when the candidate pool opens' do
      expect(described_class.open_at).to eq(
        DateTime.new(RecruitmentCycleTimetable.previous_year, 11, 19).end_of_day,
      )
    end
  end
end
