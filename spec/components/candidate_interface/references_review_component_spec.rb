require 'rails_helper'

RSpec.describe CandidateInterface::ReferencesReviewComponent, type: :component do
  it 'renders the referee name and email' do
    reference = create(:reference, :not_requested_yet)
    result = render_inline(described_class.new(references: [reference]))

    name_row = result.css('.govuk-summary-list__row')[1].text
    email_row = result.css('.govuk-summary-list__row')[2].text
    expect(name_row).to include 'Name'
    expect(name_row).to include reference.name
    expect(email_row).to include 'Email address'
    expect(email_row).to include reference.email_address
  end

  it 'renders the reference type' do
    reference = create(:reference, :not_requested_yet, referee_type: :school_based)
    result = render_inline(described_class.new(references: [reference]))

    type_row = result.css('.govuk-summary-list__row')[0].text
    expect(type_row).to include 'Reference type'
    expect(type_row).to include 'School-based'
  end

  it 'renders the relationship' do
    reference = create(:reference, :not_requested_yet)
    result = render_inline(described_class.new(references: [reference]))

    relationship_row = result.css('.govuk-summary-list__row')[3].text
    expect(relationship_row).to include 'Relationship to referee'
    expect(relationship_row).to include reference.relationship
  end

  it 'renders the correct status' do
    status_table.each do |row|
      result = render_inline(described_class.new(references: [row.reference]))

      expect(result.css(".govuk-tag.govuk-tag--#{row.colour}").text).to(
        include(t("candidate_reference_status.#{row.status_identifier}")),
      )
      next if row.info_identifier.blank?

      info = t("application_form.references.info.#{row.info_identifier}", row.info_args || {})
      if info.is_a?(Array)
        info.each { |line| expect(result.css('.govuk-summary-list__value')[4].text).to(include(line)) }
      else
        expect(result.css('.govuk-summary-list__value')[4].text).to(include(info))
      end
    end
  end

  it 'renders all references passed in' do
    reference_one = create(:reference)
    reference_two = create(:reference)

    result = render_inline(described_class.new(references: [reference_one, reference_two]))
    expect(result.text).to include reference_one.email_address
    expect(result.text).to include reference_two.email_address
  end

  context 'when reference state is "feedback_requested"' do
    let(:feedback_requested) { create(:reference, :feedback_requested) }
    let(:feedback_refused) { create(:reference, :feedback_refused) }

    it 'a cancel link is available' do
      result = render_inline(described_class.new(references: [feedback_requested, feedback_refused]))

      feedback_requested_summary = result.css('.app-summary-card')[0]
      feedback_refused_summary = result.css('.app-summary-card')[1]
      expect(feedback_requested_summary.text).to include 'Cancel request'
      expect(feedback_refused_summary.text).not_to include 'Cancel request'
    end
  end

  context 'when reference state is "not_requested_yet" and the reference is complete' do
    let(:feedback_requested) { create(:reference, :feedback_requested) }
    let(:not_requested_yet) { create(:reference, :not_requested_yet) }

    it 'a send request link is available' do
      result = render_inline(described_class.new(references: [feedback_requested, not_requested_yet]))

      feedback_requested_summary = result.css('.app-summary-card')[0]
      feedback_not_requested_summary = result.css('.app-summary-card')[1]
      expect(feedback_requested_summary.text).not_to include 'Send request'
      expect(feedback_not_requested_summary.text).to include 'Send request'
    end
  end

  context 'when reference state is "not_requested_yet" and enough references are available' do
    it 'send request link is still available' do
      application_form = create(:application_form)

      result = render_inline(described_class.new(references: [
        create(:reference, :not_requested_yet, application_form: application_form),
        create(:reference, :feedback_provided, application_form: application_form),
        create(:reference, :feedback_provided, application_form: application_form),
      ]))

      expect(result.text).to include 'Send request'
    end
  end

  context 'when reference state is "not_requested_yet" and the reference is incomplete' do
    let(:not_requested_yet) { create(:reference, :not_requested_yet, name: nil) }

    it 'a send request link is NOT available' do
      result = render_inline(described_class.new(references: [not_requested_yet]))

      feedback_not_requested_summary = result.css('.app-summary-card')[0]
      expect(feedback_not_requested_summary.text).not_to include 'Send request'
    end
  end

  context 'when reference state is "email_bounced"' do
    let(:email_bounced) { create(:reference, :email_bounced) }
    let(:feedback_provided) { create(:reference, :feedback_provided, application_form: email_bounced.application_form) }

    it 'a retry request link is available' do
      result = render_inline(described_class.new(references: [feedback_provided, email_bounced]))

      feedback_provided_summary = result.css('.app-summary-card')[0]
      email_bounced_summary = result.css('.app-summary-card')[1]
      expect(feedback_provided_summary.text).not_to include 'Retry request'
      expect(email_bounced_summary.text).to include 'Retry request'
    end
  end

  context 'when reference state is "email_bounced" but there are already 2 references provided' do
    let(:email_bounced) { create(:reference, :email_bounced) }
    let(:provided_references) { create_list(:reference, 2, :feedback_provided, application_form: email_bounced.application_form) }

    it 'a retry request link is still available' do
      result = render_inline(described_class.new(references: [*provided_references, email_bounced]))

      email_bounced_summary = result.css('.app-summary-card')[2]
      expect(email_bounced_summary.text).to include 'Retry request'
    end
  end

  context 'when reference state is "cancelled" and the reference is complete' do
    let(:cancelled) { create(:reference, :cancelled) }

    it 'a send request link is available' do
      result = render_inline(described_class.new(references: [cancelled]))

      cancelled_summary = result.css('.app-summary-card')[0]
      expect(cancelled_summary.text).to include 'Send request again'
    end
  end

  context 'when reference state is "cancelled" and the reference is incomplete' do
    let(:cancelled) { create(:reference, :cancelled, name: nil) }

    it 'a send request link is NOT available' do
      result = render_inline(described_class.new(references: [cancelled]))

      cancelled_summary = result.css('.app-summary-card')[0]
      expect(cancelled_summary.text).not_to include 'Send request again'
    end
  end

  context 'when reference state is "cancelled" but there are already 2 references provided' do
    let(:cancelled) { create(:reference, :cancelled) }
    let(:provided_references) { create_list(:reference, 2, :feedback_provided, application_form: cancelled.application_form) }

    it 'a send request link is still available' do
      result = render_inline(described_class.new(references: [cancelled, *provided_references]))

      cancelled_summary = result.css('.app-summary-card')[0]
      expect(cancelled_summary.text).to include 'Send request again'
    end
  end

  context 'rendering history' do
    let(:reference) { create(:reference, :feedback_requested) }

    it 'does not render by default' do
      result = render_inline(described_class.new(references: [reference]))
      expect(result.text).not_to include 'History'
    end

    it 'renders when argument flag is set to true' do
      result = render_inline(described_class.new(references: [reference], show_history: true))
      expect(result.text).to include 'History'
    end

    it 'does not render if reference has never been requested' do
      reference.requested_at = nil
      result = render_inline(described_class.new(references: [reference], show_history: true))
      expect(result.text).not_to include 'History'
    end

    it 'renders a reminder link if a reminder has not been sent' do
      result = render_inline(described_class.new(references: [reference], show_history: true))
      expect(result.text).to include 'Send a reminder to this referee'
    end

    it 'does not render a reminder link if a reminder has already been sent' do
      reference.reminder_sent_at = Time.zone.now
      result = render_inline(described_class.new(references: [reference], show_history: true))
      expect(result.text).not_to include 'Send a reminder to this referee'
    end
  end

private

  def status_table
    af = create(:application_form)

    not_requested_yet = create(:reference, :not_requested_yet, application_form: af)
    feedback_refused = create(:reference, :feedback_refused, application_form: af)
    email_bounced = create(:reference, :email_bounced, application_form: af)
    cancelled_at_end_of_cycle = create(:reference, :cancelled_at_end_of_cycle, application_form: af)
    cancelled = create(:reference, :cancelled, application_form: af)
    feedback_overdue = create(:reference, :feedback_overdue, application_form: af)
    sent_less_than_5_days_ago = create(:reference, :feedback_requested_less_than_5_days_ago, application_form: af)
    sent_more_than_5_days_ago = create(:reference, :feedback_requested_more_than_5_days_ago, application_form: af)
    feedback_provided = create(:reference, :feedback_provided, application_form: af)

    status_struct = Struct.new(:reference, :colour, :status_identifier, :info_identifier, :info_args)
    stub_const('Status', status_struct)
    [
      Status.new(not_requested_yet, :grey, 'not_requested_yet', ''),
      Status.new(feedback_refused, :red, 'feedback_refused', 'declined', referee_name: feedback_refused.name),
      Status.new(email_bounced, :red, 'email_bounced', ''),
      Status.new(cancelled_at_end_of_cycle, :orange, 'cancelled_at_end_of_cycle', 'cancelled_at_end_of_cycle'),
      Status.new(cancelled, :orange, 'cancelled', 'cancelled'),
      Status.new(feedback_overdue, :yellow, 'feedback_overdue', 'feedback_overdue'),
      Status.new(sent_less_than_5_days_ago, :purple, 'feedback_requested', 'feedback_requested'),
      Status.new(sent_more_than_5_days_ago, :purple, 'feedback_requested', 'feedback_requested'),
      Status.new(feedback_provided, :green, 'feedback_provided', ''),
    ]
  end

  def ordered_edit_paths(reference)
    url_helpers = Rails.application.routes.url_helpers
    [
      url_helpers.candidate_interface_references_edit_name_path(
        reference, return_to: :review
      ),
      url_helpers.candidate_interface_references_edit_email_address_path(
        reference, return_to: :review
      ),
      url_helpers.candidate_interface_references_edit_type_path(
        reference, return_to: :review
      ),
      url_helpers.candidate_interface_references_edit_relationship_path(
        reference, return_to: :review
      ),
    ]
  end
end
