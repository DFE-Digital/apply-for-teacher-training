require 'rails_helper'

RSpec.describe CandidateInterface::OfferOtherApplicationsWarningComponent do
  context 'no other applications are offered or inflight' do
    let(:choice_with_offer) { create(:application_choice, :offered) }

    it 'does not render anything' do
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq ''
    end
  end

  context 'other offer, no other applications in flight' do
    let(:application_form) { create(:application_form) }
    let(:choices) { create_list(:application_choice, 2, :offered, application_form:) }
    let(:choice_with_offer) { choices.first }

    it 'renders expected message' do
      message = 'If you accept this offer, your other offer will be automatically declined.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end

  context 'other offer, another application with interview in future' do
    let(:application_form) { create(:application_form) }
    let(:choices) { create_list(:application_choice, 2, :offered, application_form:) }
    let(:choice_with_offer) { choices.first }
    let!(:choice_with_interview) { create(:application_choice, :interviewing, application_form:) }

    it 'renders expected message' do
      message = 'If you accept this offer, your other offer will be automatically declined. Your applications that are still in progress will be withdrawn and any upcoming interviews you have will be cancelled.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end

  context 'other offer, another application in flight, interview in past' do
    let(:application_form) { create(:application_form) }
    let(:choices) { create_list(:application_choice, 2, :offered, application_form:) }
    let(:choice_with_offer) { choices.first }
    let!(:choice_with_interview) { create(:application_choice, :interviewing, application_form:, interviews: [create(:interview, :past_date_and_time)]) }

    it 'renders expected message' do
      message = 'If you accept this offer, your other offer will be automatically declined. Your applications that are still in progress will be withdrawn.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end

  context 'other offer, another application in flight, no interview' do
    let(:application_form) { create(:application_form) }
    let(:choices) { create_list(:application_choice, 2, :offered, application_form:) }
    let(:choice_with_offer) { choices.first }
    let!(:awaiting_decision_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    it 'renders the expected message' do
      message = 'If you accept this offer, your other offer will be automatically declined. Your applications that are still in progress will be withdrawn.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end

  context 'no offers, another application in flight, interview in future' do
    let(:application_form) { create(:application_form) }
    let(:choice_with_offer) { create(:application_choice, :offered, application_form:) }
    let!(:choice_with_interview) { create(:application_choice, :interviewing, application_form:) }

    it 'renders the expected message' do
      message = 'If you accept this offer, your applications that are still in progress will be withdrawn and any upcoming interviews will be cancelled.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end

  context 'no offers, another application in flight, interview in the past' do
    let(:application_form) { create(:application_form) }
    let(:choice_with_offer) { create(:application_choice, :offered, application_form:) }
    let!(:choice_with_interview) { create(:application_choice, :interviewing, application_form:, interviews: [create(:interview, :past_date_and_time)]) }

    it 'renders the expected message' do
      message = 'If you accept this offer, your applications that are still in progress will be withdrawn.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end

  context 'no offers, another application in flight without interview' do
    let(:application_form) { create(:application_form) }
    let(:choice_with_offer) { create(:application_choice, :offered, application_form:) }
    let!(:awaiting_decision_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    it 'renders the expected message' do
      message = 'If you accept this offer, your applications that are still in progress will be withdrawn.'
      result = render_inline(described_class.new(choice_with_offer:))
      expect(result.text).to eq message
    end
  end
end
