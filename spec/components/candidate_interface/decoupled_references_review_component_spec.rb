require 'rails_helper'

RSpec.describe CandidateInterface::DecoupledReferencesReviewComponent, type: :component do
  it 'renders the referee name and email' do
    reference = create(:reference, :unsubmitted)
    result = render_inline(described_class.new(references: [reference]))

    name_row = result.css('.govuk-summary-list__row')[0].text
    email_row = result.css('.govuk-summary-list__row')[1].text
    expect(name_row).to include 'Name'
    expect(name_row).to include reference.name
    expect(email_row).to include 'Email address'
    expect(email_row).to include reference.email_address
  end

  it 'renders the reference type' do
    reference = create(:reference, :unsubmitted, referee_type: :school_based)
    result = render_inline(described_class.new(references: [reference]))

    type_row = result.css('.govuk-summary-list__row')[2].text
    expect(type_row).to include 'Reference type'
    expect(type_row).to include 'School-based'
  end

  it 'renders the relationship' do
    reference = create(:reference, :unsubmitted)
    result = render_inline(described_class.new(references: [reference]))

    relationship_row = result.css('.govuk-summary-list__row')[3].text
    expect(relationship_row).to include 'Relationship to referee'
    expect(relationship_row).to include reference.relationship
  end

  it 'renders the correct status' do
    status_table.each do |row|
      result = render_inline(described_class.new(references: [row.reference]))

      expect(result.css(".govuk-tag.govuk-tag--#{row.colour}.app-tag").text).to(
        include(t("candidate_reference_status.#{row.status_identifier}")),
      )
      next if row.info_identifier.blank?

      info = t("application_form.referees.info.#{row.info_identifier}", row.info_args || {})
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

  context 'when editable is true' do
    let(:reference) { create(:reference, :unsubmitted) }
    let(:result) { render_inline(described_class.new(references: [reference], editable: true)) }

    it 'fields can be changed' do
      actions = result.css('.govuk-summary-list__actions')
      ordered_edit_paths(reference).each_with_index do |path, index|
        expect(actions[index].to_html).to include path
        expect(actions[index].text).to include 'Change'
      end
    end

    it 'the reference can be deleted' do
      expect(result.css('.app-summary-card__header').text).to include 'Delete referee'
    end
  end

  context 'when editable is false' do
    let(:reference) { create(:reference, :unsubmitted) }
    let(:result) { render_inline(described_class.new(references: [reference], editable: false)) }

    it 'fields cannot be changed' do
      expect(result.text).not_to include 'Change'
    end

    it 'the reference cannot be deleted' do
      expect(result.css('.app-summary-card__header').text).not_to include 'Delete referee'
    end
  end

  context 'when reference state is "feedback_requested"' do
    let(:feedback_requested) { create(:reference, :requested) }
    let(:feedback_refused) { create(:reference, :refused) }

    # TODO: uncomment this test when Cancel links are implemented
    it 'a cancel link is available' do
      # result = render_inline(described_class.new(references: [feedback_requested, feedback_refused]))

      # feedback_requested_summary = result.css('.app-summary-card')[0]
      # feedback_refused_summary = result.css('.app-summary-card')[1]
      # expect(feedback_requested_summary.text).to include 'Cancel request'
      # expect(feedback_refused_summary.text).not_to include 'Cancel request'
    end
  end

  context 'when reference state is "not_requested_yet" and the reference is complete' do
    let(:feedback_requested) { create(:reference, :requested) }
    let(:not_requested_yet) { create(:reference, :not_requested_yet) }

    it 'a send request link is available' do
      FeatureFlag.activate(:decoupled_references)
      result = render_inline(described_class.new(references: [feedback_requested, not_requested_yet]))

      feedback_requested_summary = result.css('.app-summary-card')[0]
      feedback_not_requested_summary = result.css('.app-summary-card')[1]
      expect(feedback_requested_summary.text).not_to include 'Send request'
      expect(feedback_not_requested_summary.text).to include 'Send request'
    end
  end

  context 'when reference state is "not_requested_yet" and the reference is incomplete' do
    let(:not_requested_yet) { create(:reference, :not_requested_yet, name: nil) }

    it 'a send request link is NOT available' do
      FeatureFlag.activate(:decoupled_references)
      result = render_inline(described_class.new(references: [not_requested_yet]))

      feedback_not_requested_summary = result.css('.app-summary-card')[0]
      expect(feedback_not_requested_summary.text).not_to include 'Send request'
    end
  end

  context 'when reference state is "cancelled" and the reference is complete' do
    let(:feedback_requested) { create(:reference, :requested) }
    let(:cancelled) { create(:reference, :cancelled) }

    it 'a re-send request link is available' do
      FeatureFlag.activate(:decoupled_references)
      result = render_inline(described_class.new(references: [feedback_requested, cancelled]))

      feedback_requested_summary = result.css('.app-summary-card')[0]
      feedback_cancelled_summary = result.css('.app-summary-card')[1]
      expect(feedback_requested_summary.text).not_to include 'Send request again'
      expect(feedback_cancelled_summary.text).to include 'Send request again'
    end
  end

  context 'when reference state is "cancelled" and the reference is incomplete' do
    let(:cancelled) { create(:reference, :cancelled, name: nil) }

    it 'a send request link is NOT available' do
      FeatureFlag.activate(:decoupled_references)
      result = render_inline(described_class.new(references: [cancelled]))

      feedback_not_requested_summary = result.css('.app-summary-card')[0]
      expect(feedback_not_requested_summary.text).not_to include 'Send request again'
    end
  end

  context 'when reference state is "cancelled" but there are already 2 references provided' do
    let(:cancelled) { create(:reference, :cancelled) }
    let(:provided_references) { create_list(:reference, 2, :complete, application_form: cancelled.application_form) }

    it 'a send request link is NOT available' do
      FeatureFlag.activate(:decoupled_references)
      result = render_inline(described_class.new(references: [cancelled, *provided_references]))

      feedback_not_requested_summary = result.css('.app-summary-card')[0]
      expect(feedback_not_requested_summary.text).not_to include 'Send request again'
    end
  end

private

  def status_table
    af = create(:application_form)

    not_requested_yet = create(:reference, :unsubmitted, application_form: af)
    feedback_refused = create(:reference, :refused, application_form: af)
    email_bounced = create(:reference, :email_bounced, application_form: af)
    cancelled_at_end_of_cycle = create(:reference, :cancelled_at_end_of_cycle, application_form: af)
    cancelled = create(:reference, :cancelled, application_form: af)
    feedback_overdue = create(:reference, :feedback_overdue, application_form: af)
    sent_less_than_5_days_ago = create(:reference, :sent_less_than_5_days_ago, application_form: af)
    sent_more_than_5_days_ago = create(:reference, :sent_more_than_5_days_ago, application_form: af)
    feedback_provided = create(:reference, :complete, application_form: af)

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
      url_helpers.candidate_interface_decoupled_references_edit_name_path(
        reference, return_to: :review
      ),
      url_helpers.candidate_interface_decoupled_references_edit_email_address_path(
        reference, return_to: :review
      ),
      url_helpers.candidate_interface_decoupled_references_edit_type_path(
        reference, return_to: :review
      ),
      url_helpers.candidate_interface_decoupled_references_edit_relationship_path(
        reference, return_to: :review
      ),
    ]
  end
end
