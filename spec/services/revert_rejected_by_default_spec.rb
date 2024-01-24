require 'rails_helper'

RSpec.describe RevertRejectedByDefault, CycleTimetableHelper.mid_cycle(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR), :continuous_applications do
  let!(:form_with_single_rbd) do
    create(:application_form).tap do |form|
      create(:application_choice, :rejected_by_default, application_form: form)
    end
  end

  let!(:form_without_rbd) do
    create(:application_form).tap do |form|
      create(:application_choice, :awaiting_provider_decision, application_form: form)
    end
  end

  let!(:form_with_two_rbds) do
    create(:application_form).tap do |form|
      create(:application_choice, :rejected_by_default, application_form: form)
      create(:application_choice, :rejected_by_default, application_form: form)
    end
  end

  let!(:form_with_rbd_and_offer) do
    create(:application_form).tap do |form|
      create(:application_choice, :rejected_by_default, application_form: form)
      create(:application_choice, :offered, application_form: form)

      # :grimacing: we have to do this manually. Factories should really use
      # the MakeOffer machinery.
      SetDeclineByDefault.new(application_form: form).call
    end
  end

  let!(:form_with_rbd_and_accepted_offer) do
    create(:application_form).tap do |form|
      create(:application_choice, :rejected_by_default, application_form: form)
      create(:application_choice, :accepted, application_form: form)
    end
  end

  let(:new_rbd_date) { 1.day.from_now }

  def call_service
    described_class.new(
      ids: ApplicationForm.pluck(:id),
      new_rbd_date:,
    ).call
  end

  it 'correctly reverts an RBD application without siblings' do
    choice = form_with_single_rbd.application_choices.first

    call_service

    expect(choice.reload.reject_by_default_at).to be_within(1.minute).of new_rbd_date
  end

  it 'correctly reverts all RBD applications for a given form' do
    choices = form_with_two_rbds.application_choices

    call_service

    choices.each do |choice|
      expect(choice.reload.reject_by_default_at).to be_within(1.minute).of new_rbd_date
    end
  end

  it 'correctly no-ops on an application without RBDs' do
    choice = form_without_rbd.application_choices.first

    expect {
      call_service
    }.not_to(change { choice.reload.reject_by_default_at })
  end

  it 'correctly handles an application with an offer awaiting decision', :with_audited do
    # in this case either the RBD or the offer would have caused the application to enter DBD.
    # we need to prevent DBD, which is accomplished by removing the date.
    choices = form_with_rbd_and_offer.application_choices

    # assert that we correctly set a DBD on the offered app or this spec is meaningless
    expect(choices.map(&:decline_by_default_at).compact.first).to be_present

    call_service

    choices.reload

    expect(choices.map(&:decline_by_default_at)).to all be_nil
    expect(choices.map(&:decline_by_default_days)).to all be_nil

    choice_with_offer = form_with_rbd_and_offer.application_choices.find_by(status: :offer)
    changes = choice_with_offer.audits.last.audited_changes

    expect(changes.keys).to match_array %w[decline_by_default_at decline_by_default_days]
    expect(changes.values.map(&:last)).to all be_nil
  end

  it 'does not touch RBD when an offer has been accepted' do
    statuses = %w[rejected pending_conditions]
    choices = form_with_rbd_and_accepted_offer.application_choices
    expect(choices.pluck(:status)).to match_array(statuses)

    call_service

    expect(choices.reload.pluck(:status)).to match_array(statuses)
  end

  it 'clears reasons for rejection fields' do
    form = create(:application_form)
    rr_choice = create(:application_choice, :rejected_by_default, rejection_reason: 'RBD done it', application_form: form)
    sr4r_choice = create(:application_choice, :rejected_by_default, :with_old_structured_rejection_reasons, application_form: form)

    described_class.new(
      ids: form.id,
      new_rbd_date:,
    ).call

    expect(rr_choice.reload.rejection_reason).to be_nil
    expect(sr4r_choice.reload.structured_rejection_reasons).to be_nil
  end
end
