require 'rails_helper'

RSpec.describe CandidateInterface::FindChangedApplyAgainApplications do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  def setup_apply_again_application
    @original_application = create(
      :completed_application_form,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )
    create(:degree_qualification, application_form: @original_application)
    @apply_again_application = DuplicateApplication.new(
      @original_application,
      target_phase: 'apply_2',
    ).duplicate
    @apply_again_application.update(submitted_at: Time.zone.now)
  end

  def setup_multiple_apply_again_applications
    @original_application = create(
      :completed_application_form,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )
    create(:degree_qualification, application_form: @original_application)
    @apply_again_application = DuplicateApplication.new(
      @original_application,
      target_phase: 'apply_2',
    ).duplicate
    @second_apply_again_application = DuplicateApplication.new(
      @apply_again_application,
      target_phase: 'apply_2',
    ).duplicate
    @apply_again_application.update(submitted_at: Time.zone.now)
    @second_apply_again_application.update(submitted_at: Time.zone.now)
  end

  context 'with two apply again applications' do
    it 'does not return identical applications' do
      setup_multiple_apply_again_applications
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(0)
    end

    it 'returns candidates for which the personal_statement was changed in the first apply again application' do
      setup_multiple_apply_again_applications
      @apply_again_application.update(becoming_a_teacher: 'new statement')
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end

    it 'returns candidates for which the personal_statement was changed in the second apply again application' do
      setup_multiple_apply_again_applications
      @second_apply_again_application.update(becoming_a_teacher: 'new statement')
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end

    it 'returns candidate for which the personal_statement was changed in both apply again application' do
      setup_multiple_apply_again_applications
      @apply_again_application.update(becoming_a_teacher: 'new statement')
      @second_apply_again_application.update(becoming_a_teacher: 'newer statement')
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end
  end

  context 'with a single apply again application' do
    it 'does not return identical applications' do
      setup_apply_again_application
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(0)
    end

    it 'returns applications for which the personal_statement was changed' do
      setup_apply_again_application
      @apply_again_application.update(becoming_a_teacher: 'new statement')
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end

    it 'returns applications for which subject_knowledge was changed' do
      setup_apply_again_application
      @apply_again_application.update(subject_knowledge: 'new learnings')
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end

    it 'returns applications for which a new qualification was added' do
      setup_apply_again_application
      create(:gcse_qualification, application_form: @apply_again_application)
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end

    it 'returns applications for which a qualification was changed' do
      setup_apply_again_application
      @apply_again_application.application_qualifications.first.update(
        institution_name: 'University of South Oxfordshire',
      )
      expect(described_class.new.all_candidate_count).to be(1)
      expect(described_class.new.changed_candidate_count).to be(1)
    end
  end
end
