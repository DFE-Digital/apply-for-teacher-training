require 'rails_helper'

RSpec.describe InterviewUpdateValidator do
  before { stub_const('InterviewModelClass', model_class) }

  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :application_choice, :provider
      attr_accessor :date_and_time, :location, :additional_details
      attr_accessor :cancelled_at, :cancellation_reason

      validates_with InterviewUpdateValidator, attributes:
        %i[provider date_and_time location additional_details cancelled_at cancellation_reason]

      # instead of ActiveModel::Dirty, which is more work
      def provider_change; end
      def date_and_time_change; end
      def location_change; end
      def additional_details_change; end
      def cancellation_reason_change; end

      def changed?
        true
      end
    end
  end

  let(:model) do
    InterviewModelClass.new(
      application_choice: application_choice,
      provider: provider,
      date_and_time: date_and_time,
      location: location,
      additional_details: additional_details,
    )
  end

  let(:application_choice) { create(:application_choice, :with_scheduled_interview, course_option: course_option) }
  let(:course_option) { create(:course_option) }
  let(:provider) { course_option.course.provider }
  let(:date_and_time) { 5.days.from_now }
  let(:location) { 'Zoom call' }
  let(:additional_details) { 'Some notes' }

  context 'no changes' do
    it 'is valid' do
      allow(model).to receive(:changed?).and_return(false)
      model.date_and_time = 5.days.ago

      expect(model).to be_valid
    end
  end

  context 'date_and_time updates' do
    context 'changes from future to past' do
      it 'is not valid' do
        old_time = 5.days.from_now
        new_time = 5.days.ago
        allow(model).to receive(:date_and_time_change).and_return([old_time, new_time])

        expect(model).not_to be_valid
      end
    end

    context 'changes from past to future' do
      it 'is not valid' do
        old_time = 5.days.ago
        new_time = 5.days.from_now
        allow(model).to receive(:date_and_time_change).and_return([old_time, new_time])

        expect(model).not_to be_valid
      end
    end

    context 'changes from past to past' do
      it 'is not valid' do
        old_time = 5.days.ago
        new_time = 10.days.ago
        allow(model).to receive(:date_and_time_change).and_return([old_time, new_time])

        expect(model).not_to be_valid
      end
    end

    context 'changes from future to future' do
      it 'is valid' do
        old_time = 5.days.from_now
        new_time = 10.days.from_now
        allow(model).to receive(:date_and_time_change).and_return([old_time, new_time])

        expect(model).to be_valid
      end
    end

    context 'changes from future to after RBD date' do
      it 'is not valid' do
        old_time = 5.days.from_now
        new_time = application_choice.reject_by_default_at + 1.second
        allow(model).to receive(:date_and_time_change).and_return([old_time, new_time])

        expect(model).not_to be_valid
      end
    end
  end

  context 'any change to an interview that has passed' do
    it 'is not valid' do
      model.date_and_time = 5.days.ago
      model.additional_details = 'Changed value'

      expect(model).not_to be_valid
    end
  end
end
