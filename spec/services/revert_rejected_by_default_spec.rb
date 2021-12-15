require 'rails_helper'

RSpec.describe RevertRejectedByDefault do
  let!(:form_with_single_rbd) do
    form = create(:application_form)
    create(:application_choice, :with_rejection_by_default, application_form: form)
    form
  end

  let!(:form_without_rbd) do
    form = create(:application_form)
    create(:application_choice, :awaiting_provider_decision, application_form: form)
    form
  end

  let!(:form_with_two_rbds) do
    form = create(:application_form)
    create(:application_choice, :with_rejection_by_default, application_form: form)
    create(:application_choice, :with_rejection_by_default, application_form: form)
    form
  end

  let!(:form_with_rbd_and_offer) do
    form = create(:application_form)
    create(:application_choice, :with_rejection_by_default, application_form: form)
    create(:application_choice, :with_offer, application_form: form)

    # :grimacing: we have to do this manually. Factories should really use
    # the MakeOffer machinery.
    SetDeclineByDefault.new(application_form: form).call

    # Send a DBD chaser to the candidate. We’ll want to delete this so that
    # when DBD starts again they can get a fresh email.
    SendChaseEmailToCandidate.call(application_form: form)

    form
  end

  let(:new_rbd_date) { 1.day.from_now }

  def call_service
    described_class.new(
      ids: ApplicationForm.pluck(:id),
      new_rbd_date: new_rbd_date,
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

  it 'correctly handles an application with an offer awaiting decision' do
    # in this case either the RBD or the offer would have caused the application to enter DBD.
    # we need to prevent DBD, which is accomplished by removing the date.
    choices = form_with_rbd_and_offer.application_choices

    # assert that we correctly set a DBD on the offered app and that we sent a chaser,
    # or this spec is meaningless
    expect(choices.map(&:decline_by_default_at).compact.first).to be_present
    expect(form_with_rbd_and_offer.chasers_sent).to be_present

    call_service

    choices.reload

    expect(choices.map(&:decline_by_default_at)).to all be_nil
    expect(choices.map(&:decline_by_default_days)).to all be_nil
    expect(form_with_rbd_and_offer.reload.chasers_sent).to be_empty
  end
end
