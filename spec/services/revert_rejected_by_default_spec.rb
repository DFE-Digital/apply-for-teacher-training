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
end
