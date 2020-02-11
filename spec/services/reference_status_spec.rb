require 'rails_helper'

RSpec.describe ReferenceStatus do
  describe '#still_more_references_needed?' do
    it 'knows if all references have come back' do
      application_form = create(:application_form)
      create(:reference, :complete, application_form: application_form)
      create(:reference, :complete, application_form: application_form)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.still_more_references_needed?).to be(false)
      expect(status.references_that_needed_to_be_replaced).to match_array([])
      expect(status.needs_to_draft_another_reference?).to be(false)
    end

    it 'knows if we are still waiting on references' do
      application_form = create(:application_form)
      create(:reference, :requested, application_form: application_form)
      create(:reference, :requested, application_form: application_form)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.still_more_references_needed?).to be(false)
      expect(status.references_that_needed_to_be_replaced).to match_array([])
      expect(status.needs_to_draft_another_reference?).to be(false)
    end

    it 'knows if referees need to be replaced' do
      application_form = create(:application_form)
      create(:reference, :complete, application_form: application_form)
      overdue = create(:reference, :requested, application_form: application_form, requested_at: Time.zone.now - 30.days)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.still_more_references_needed?).to be(true)
      expect(status.references_that_needed_to_be_replaced).to match_array([overdue])
      expect(status.needs_to_draft_another_reference?).to be(true)
    end

    it 'knows if referees need to be replaced if we are waiting for the other one' do
      application_form = create(:application_form)
      create(:reference, :requested, application_form: application_form)
      refused = create(:reference, :refused, application_form: application_form, requested_at: Time.zone.now - 30.days)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.still_more_references_needed?).to be(true)
      expect(status.number_of_references_that_currently_need_replacing).to be(1)
      expect(status.references_that_needed_to_be_replaced).to match_array([refused])
      expect(status.needs_to_draft_another_reference?).to be(true)
    end

    it 'knows if referees need to be replaced, but new reference is already requested' do
      application_form = create(:application_form)
      create(:reference, :complete, application_form: application_form)
      overdue = create(:reference, :requested, application_form: application_form, requested_at: Time.zone.now - 30.days)
      create(:reference, :requested, replacement: true, application_form: application_form)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.still_more_references_needed?).to be(false)
      expect(status.references_that_needed_to_be_replaced).to match_array([overdue])
      expect(status.needs_to_draft_another_reference?).to be(false)
    end

    it 'knows if referees need to be replaced, but new reference is already drafted (but not requested)' do
      application_form = create(:application_form)
      create(:reference, :complete, application_form: application_form)
      overdue = create(:reference, :requested, application_form: application_form, requested_at: Time.zone.now - 30.days)
      create(:reference, :unsubmitted, replacement: true, application_form: application_form)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.still_more_references_needed?).to be(true)
      expect(status.references_that_needed_to_be_replaced).to match_array([overdue])
      expect(status.needs_to_draft_another_reference?).to be(false)
    end

    it 'knows if 2 referees need to be replaced, a new reference is already drafted (but not requested)' do
      application_form = create(:application_form)
      bounced = create(:reference, :email_bounced, application_form: application_form)
      overdue = create(:reference, :requested, application_form: application_form, requested_at: Time.zone.now - 100.days)
      create(:reference, :unsubmitted, replacement: true, application_form: application_form)

      status = ReferenceStatus.new(application_form.reload)

      expect(status.references_that_needed_to_be_replaced).to match_array([bounced, overdue])
      expect(status.still_more_references_needed?).to be(true)
      expect(status.needs_to_draft_another_reference?).to be(true)
    end
  end
end
