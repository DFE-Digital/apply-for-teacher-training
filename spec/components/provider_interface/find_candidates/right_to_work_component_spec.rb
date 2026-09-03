require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::RightToWorkComponent, type: :component do
  context 'candidates is british or irish' do
    it 'shows the immigration status' do
      application_form = build(:application_form, right_to_work_or_study: nil, first_nationality: 'British')

      render_inline(described_class.new(application_form:))

      expect(page).to have_text 'Not required'
      expect(page).to have_text 'Visa or immigration status'
      expect(page).to have_text 'British or Irish citizen'
    end
  end

  context 'candidates has visa and does not need sponsorship' do
    it 'renders immigration status' do
      application_form = build(:application_form, right_to_work_or_study: 'yes', immigration_status: 'indefinite_leave_to_remain_in_the_uk')

      render_inline(described_class.new(application_form:))

      expect(page).to have_text 'Not required'
      expect(page).to have_text 'Visa or immigration status'
      expect(page).to have_text 'Indefinite leave to remain in the UK'
    end
  end

  context 'candidate requires sponsorship' do
    it 'does not render immigration status' do
      application_form = build(:application_form, right_to_work_or_study: 'no')

      render_inline(described_class.new(application_form:))

      expect(page).to have_text 'Required'
      expect(page).to have_no_text 'Visa or immigration status'
    end
  end

  context 'candidate has entered their visa expiry' do
    it 'renders the visa expiry date' do
      application_form = build(
        :application_form,
        right_to_work_or_study: 'yes',
        immigration_status: 'indefinite_leave_to_remain_in_the_uk',
        visa_expired_at: '01/01/2028',
      )

      render_inline(described_class.new(application_form:))

      expect(page).to have_text 'Not required'
      expect(page).to have_text 'Visa or immigration status'
      expect(page).to have_text 'Indefinite leave to remain in the UK'
      expect(page).to have_text 'Visa expiry date'
      expect(page).to have_text '1 January 2028'
    end
  end

  context 'candidate has enter their visa explanation' do
    let(:application_form) do
      build(
        :application_form,
        right_to_work_or_study: 'yes',
        immigration_status: 'indefinite_leave_to_remain_in_the_uk',
        visa_expired_at: '01/01/2028',
      )
    end

    context 'for one application choice' do
      before do
        create(:application_choice, :awaiting_provider_decision, application_form:, visa_explanation: 'expires_after_course')
      end

      it 'renders the visa explanation' do
        render_inline(described_class.new(application_form:))

        expect(page).to have_text 'Not required'
        expect(page).to have_text 'Visa or immigration status'
        expect(page).to have_text 'Indefinite leave to remain in the UK'
        expect(page).to have_text 'Visa expiry date'
        expect(page).to have_text '1 January 2028'
        expect(page).to have_text 'How will you complete your studies?'
        expect(page).to have_text 'My visa expires after the course ends'
      end
    end

    context 'for mulitple application choices' do
      before do
        create(:application_choice, :awaiting_provider_decision, application_form:, visa_explanation: 'expires_after_course')
        create(:application_choice, :awaiting_provider_decision, application_form:, visa_explanation: 'renew')
        create(
          :application_choice,
          :awaiting_provider_decision,
          application_form:,
          visa_explanation: 'other',
          visa_explanation_details: 'I have a right to work',
        )
      end

      it 'renders the visa explanation for each application choice' do
        render_inline(described_class.new(application_form:))

        expect(page).to have_text 'Not required'
        expect(page).to have_text 'Visa or immigration status'
        expect(page).to have_text 'Indefinite leave to remain in the UK'
        expect(page).to have_text 'Visa expiry date'
        expect(page).to have_text '1 January 2028'
        expect(page).to have_text 'How will you complete your studies?'
        expect(page).to have_text 'My visa expires after the course ends'
        expect(page).to have_text 'I will be able to renew or extend my current visa'
        expect(page).to have_text 'Other:I have a right to work'
      end
    end
  end
end
