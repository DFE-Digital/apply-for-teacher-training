require 'rails_helper'

RSpec.describe Healthchecks::SimulatedFailureCheck do
  subject { described_class.new }

  context 'when the feature flag `force_ok_computer_to_fail` is on' do
    before do
      FeatureFlag.activate('force_ok_computer_to_fail')
    end

    it { is_expected.to have_message('force_ok_computer_to_fail is on') }
    it { is_expected.not_to be_successful_check }
  end

  context 'when the feature flag `force_ok_computer_to_fail` is off' do
    before do
      FeatureFlag.deactivate('force_ok_computer_to_fail')
    end

    it { is_expected.to have_message('force_ok_computer_to_fail is off') }
    it { is_expected.to be_successful_check }
  end
end
