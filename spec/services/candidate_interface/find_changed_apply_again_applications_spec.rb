require 'rails_helper'

RSpec.describe CandidateInterface::FindChangedApplyAgainApplications do
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
  end

  it 'does not return identical applications' do
    setup_apply_again_application
    expect(described_class.new.call.count).to be(0)
  end

  it 'returns applications for which the personal_statement was changed' do
    setup_apply_again_application
    @apply_again_application.update(becoming_a_teacher: 'new statement')
    expect(described_class.new.call.count).to be(1)
  end

  it 'returns applications for which subject_knowledge was changed' do
    setup_apply_again_application
    @apply_again_application.update(subject_knowledge: 'new learnings')
    expect(described_class.new.call.count).to be(1)
  end

  it 'returns applications for which a new qualification was added' do
    setup_apply_again_application
    create(:gcse_qualification, application_form: @apply_again_application)
    expect(described_class.new.call.count).to be(1)
  end

  it 'returns applications for which a new qualification was added' do
    setup_apply_again_application
    @apply_again_application.application_qualifications.first.update(
      awarding_body: 'University of South Oxfordshire',
    )
    expect(described_class.new.call.count).to be(1)
  end
end
