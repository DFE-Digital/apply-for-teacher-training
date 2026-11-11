require 'rails_helper'

RSpec.describe SupportInterface::DuplicateMatchesCandidatesTableComponent do
  let(:postcode) { 'W6 9BH' }
  let(:last_name) { 'Thompson' }
  let(:date_of_birth) { Date.new(2000, 3, 7) }
  let(:candidate_1) { create(:candidate, account_locked: true) }
  let(:candidate_2) { create(:candidate, submission_blocked: true, created_at: 1.month.ago) }
  let(:application_form_1) do
    create(
      :application_form,
      :minimum_info,
      :with_safeguarding_issues_disclosed,
      last_name:,
      submitted_at: 1.year.ago,
      date_of_birth:,
      address_line1: nil,
      address_line2: nil,
      postcode:,
      candidate: candidate_1,
    )
  end
  let(:application_form_2) do
    create(
      :application_form,
      :minimum_info,
      last_name:,
      date_of_birth:,
      address_line1: nil,
      address_line2: nil,
      postcode:,
      candidate: candidate_2,
    )
  end
  let(:submitted_application_choice_1a) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: application_form_1,
    )
  end
  let(:submitted_application_choice_1b) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: application_form_1,
    )
  end
  let(:offered_application_choice_1) do
    create(
      :application_choice,
      :offered,
      application_form: application_form_1,
    )
  end
  let(:unsubmitted_application_choice_2) do
    create(
      :application_choice,
      :unsubmitted,
      application_form: application_form_2,
    )
  end
  let(:application_form_1_reference) do
    create(
      :reference,
      :feedback_provided,
      application_form: application_form_1,
      safeguarding_concerns_status: 'has_safeguarding_concerns_to_declare',
    )
  end
  let(:duplicate_match) { create(:duplicate_match, last_name:, date_of_birth:, postcode:, candidates: [candidate_1, candidate_2]) }
  let(:one_login_auth_1) { create(:one_login_auth, candidate: candidate_1) }

  before do
    duplicate_match
    application_form_1
    application_form_2
    submitted_application_choice_1a
    submitted_application_choice_1b
    offered_application_choice_1
    unsubmitted_application_choice_2
    one_login_auth_1
    application_form_1_reference
  end

  it 'renders the correct match descriptions' do
    result = render_inline(
      described_class.new(duplicate_match),
    )

    duplicate_match.candidates.order(created_at: :desc).each_with_index do |candidate, index|
      rows = result.css('tr')

      candidate_index = index + 1
      email_row = format_row(rows[0])
      expect(email_row[0]).to have_text('Email address')
      expect(email_row[candidate_index]).to eq(candidate.email_address)
      expect(result.css('a[href]')[index].attributes['href'].value).to eq(
        Rails.application.routes.url_helpers.support_interface_candidate_path(candidate),
      )

      one_login_row = format_row(rows[1])
      expect(one_login_row[0]).to have_text('One Login email address')
      if candidate == candidate_1
        expect(one_login_row[candidate_index]).to eq(one_login_auth_1.email_address)
      end

      created_at_row = format_row(rows[2])
      expect(created_at_row[0]).to have_text('Created at')
      expect(created_at_row[candidate_index]).to eq(candidate.created_at.to_fs(:govuk_date_and_time))

      name_row = format_row(rows[3])
      expect(name_row[0]).to have_text('Name')
      expect(name_row[candidate_index]).to eq(candidate.current_application.full_name)

      date_of_birth_row = format_row(rows[4])
      expect(date_of_birth_row[0]).to have_text('Date of birth')
      expect(date_of_birth_row[candidate_index]).to eq(candidate.current_application.date_of_birth.to_fs(:govuk_date_short_month))

      address_row = format_row(rows[5])
      expect(address_row[0]).to have_text('Address')
      expect(address_row[candidate_index]).to eq(postcode)

      applications_submitted_row = format_row(rows[6])
      expect(applications_submitted_row[0]).to have_text('Applications submitted')
      if candidate == candidate_1
        expect(applications_submitted_row[candidate_index]).to eq('3')
      else
        expect(applications_submitted_row[candidate_index]).to eq('0')
      end

      application_progress_row = format_row(rows[7])
      expect(application_progress_row[0]).to have_text('Application progress')

      if candidate == candidate_1
        expect(application_progress_row[1]).to have_text('1 x Offer made')
        expect(application_progress_row[2]).to have_text('2 x Awaiting provider decision')
      else
        expect(application_progress_row[3]).to have_text('1 x Not submitted yet')
      end

      safeguarding_row = format_row(rows[8])
      expect(safeguarding_row[0]).to have_text('Safeguarding information')
      if candidate == candidate_1
        expect(safeguarding_row[1]).to have_text('Safeguarding issue declared')
        expect(safeguarding_row[2]).to have_text('Reference with safeguarding issue')
      else
        expect(safeguarding_row[3]).to eq('None')
      end

      account_status_row = format_row(rows[9])
      expect(account_status_row[0]).to have_text('Account status')
      if candidate == candidate_1
        expect(account_status_row[1]).to eq('Locked')
      else
        expect(account_status_row[2]).to eq('Application submission blocked')
      end

      actions_row = format_row(rows[10])
      expect(actions_row[0]).to have_text('Actions')

      # expect(result.css('a')[index].text).to eq(candidate.email_address)
      # expect(result.text).to include(candidate.created_at.to_fs(:govuk_date_and_time))
      # expect(result.text).to include(candidate.current_application.full_name)
      # expect(result.text).to include(candidate.current_application.date_of_birth.to_fs(:govuk_date_short_month))
      # candidate.current_application.full_address.each do |address_line|
      #   expect(result.text).to include(address_line)
      # end
      # expect(result.text).to include(candidate.current_application.submitted_at&.to_fs(:govuk_date_and_time) || 'Not submitted')
      # expect(result.text).to include(index.zero? ? 'Account locked' : 'Application submission blocked')
    end
  end

private

  def format_row(row)
    row.text.split("\n").map { |cell| cell.gsub("\n", '').strip }.compact_blank
  end
end
