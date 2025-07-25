require 'rails_helper'

RSpec.describe DecisionsAPIData do
  subject(:presenter) { DecisionsDataClass.new(application_choice) }

  let(:application_form) { create(:application_form, :minimum_info) }
  let(:decisions_data_class) do
    Class.new do
      include DecisionsAPIData

      attr_accessor :application_choice, :application_form

      def initialize(application_choice)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
      end
    end
  end

  before do
    stub_const('DecisionsDataClass', decisions_data_class)
  end

  describe '#withdrawal' do
    let(:withdrawn_at) { Time.zone.local(2019, 1, 1, 0, 0, 0) }
    let!(:application_choice) { create(:application_choice, :withdrawn, application_form:, withdrawn_at:) }

    it 'returns a withdrawal object' do
      expect(presenter.withdrawal).to eq({ reason: nil, date: withdrawn_at.iso8601 })
    end
  end

  describe '#rejection' do
    let(:rejected_at) { Time.zone.local(2019, 1, 1, 0, 0, 0) }
    let!(:application_choice) do
      create(
        :application_choice,
        :rejected,
        application_form:,
        rejected_at:,
        rejection_reason: 'Course full',
        rejection_reasons_type: 'rejection_reason',
      )
    end

    it 'returns a rejection object' do
      expect(presenter.rejection).to eq({ reason: 'Course full', date: rejected_at.iso8601 })
    end

    it 'returns a rejection object with a truncated reason when the character limit is exceeded' do
      application_choice.rejection_reason = 'Course full' * 65000
      allow(Sentry).to receive(:capture_message)

      presenter.rejection

      expect(presenter.rejection[:reason].length).to be(65535)
      expect(presenter.rejection[:reason]).to end_with(described_class::OMISSION_TEXT)
      expect(presenter.rejection[:date]).to eq(rejected_at.iso8601)
    end

    context 'when there is a withdrawn offer' do
      let(:withdrawn_at) { Time.zone.local(2019, 1, 1, 0, 0, 0) }
      let(:application_choice) { create(:application_choice, :rejected, application_form:, rejection_reason: nil, offer_withdrawn_at: withdrawn_at, offer_withdrawal_reason: 'Course full') }

      it 'returns a rejection object' do
        expect(presenter.rejection).to eq({ reason: 'Course full', date: withdrawn_at.iso8601 })
      end
    end

    context 'when there is no feedback' do
      let(:application_choice) { create(:application_choice, :rejected_by_default, application_form:, rejected_at:) }

      it 'returns a rejection object with a custom rejection reason' do
        expect(presenter.rejection).to eq({ reason: 'Not entered', date: rejected_at.iso8601 })
      end
    end
  end

  describe '#offer' do
    context 'when there is no offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :awaiting_provider_decision) }

      it 'returns nil' do
        expect(presenter.offer).to be_nil
      end
    end

    context 'when there is an offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :offered) }

      it 'includes an offer_made_at date for offers' do
        expect(presenter.offer[:offer_made_at]).to be_present
      end

      it 'includes the offered course' do
        expect(presenter.offer[:course][:course_code]).to eq(application_choice.current_course_option.course.code)
      end
    end

    context 'when there is an offer with SKE conditions' do
      let(:application_choice) do
        create(:application_choice, :with_completed_application_form, :offered)
      end

      before do
        create(:ske_condition, offer: application_choice.offer)
        application_choice.reload
      end

      it 'includes the SKE condition as well as standard conditions' do
        expect(presenter.offer[:conditions]).to include('Mathematics subject knowledge enhancement course')
      end
    end

    context 'when there is an accepted offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :accepted) }

      it 'includes an accepted_at date for accepted offers' do
        expect(presenter.offer[:offer_accepted_at]).to be_present
      end
    end

    context 'when there is a declined offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :declined) }

      it 'includes a declined_at date for declined offers' do
        expect(presenter.offer[:offer_declined_at]).to be_present
      end
    end
  end
end
