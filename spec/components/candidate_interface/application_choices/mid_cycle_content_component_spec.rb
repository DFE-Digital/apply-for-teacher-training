require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::MidCycleContentComponent do
  include Rails.application.routes.url_helpers

  let(:application_form) { build_stubbed(:application_form) }
  let(:component) { described_class.new(application_form: application_form) }

  describe '#content_component' do
    it 'returns a MidCycleAddMoreContentComponent when the candidate can add more choices' do
      allow(application_form).to receive_messages(
        can_add_more_choices?: true,
        unsuccessful_limit_reached?: false,
      )

      expect(component.content_component).to be_a(CandidateInterface::ApplicationChoices::MidCycleAddMoreContentComponent)
    end

    it 'returns a MidCycleUnsuccessfulContentComponent when the candidate has reached the unsuccessful limit' do
      allow(application_form).to receive_messages(
        can_add_more_choices?: false,
        unsuccessful_limit_reached?: true,
      )

      expect(component.content_component).to be_a(CandidateInterface::ApplicationChoices::MidCycleUnsuccessfulContentComponent)
    end

    it 'returns a MidCycleCreationLimitComponent when the candidate can not add more choices and has not reached the unsuccessful limit' do
      allow(application_form).to receive_messages(
        can_add_more_choices?: false,
        unsuccessful_limit_reached?: false,
      )

      expect(component.content_component).to be_a(CandidateInterface::ApplicationChoices::MidCycleCreationLimitContentComponent)
    end
  end
end
