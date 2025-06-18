require 'rails_helper'

RSpec.describe CandidateInterface::InactiveDateCalculator do
  subject(:calculator) { described_class.new(effective_date: Time.zone.now) }

  let(:application_choice) { create(:application_choice, :unsubmitted) }

  describe 'inactive calculation' do
    submitted_vs_inactive_dates = [
      ['28 Oct 2023 9:00:00 AM BST', '11 Dec 2023 23:59:59 PM GMT', 30, 'near the BST/GMT boundary'],
      ['1 Apr 2024 9:00:00 AM BST',  '15 May 2024 23:59:59 PM BST', 30, 'safely within BST'],
      ['4 Jan 2024 11:00:00 PM GMT', '15 Feb 2024 23:59:59 PM GMT', 30, 'safely within GMT'],
      ['1 Jul 2024 11:00:00 PM BST', '12 Aug 2024 23:59:59 PM BST', 30, 'during summer period'],
      ['01 Dec 2023 12:00:00 PM GMT', '17 January 2024 23:59:59 PM GMT', 30, 'near the Christmas holidays'],
      ['02 Sep 2024 0:00:00 AM BST', '25 Sep 2024 23:59:59 PM BST', 17, 'close to the apply deadline'],
      ['16 Sep 2024 0:00:00 AM BST', '25 Sep 2024 23:59:59 PM BST', 7, 'very close to the apply deadline'],
    ].freeze

    submitted_vs_inactive_dates.each do |submitted, correct_rbd, inactive_days, test_case|
      it "is correct when the application is delivered #{test_case}" do
        travel_temporarily_to(Time.zone.parse(submitted)) do
          expect(calculator.inactive_date).to be_within(1.second).of(Time.zone.parse(correct_rbd))
          expect(calculator.inactive_days).to eq inactive_days
        end
      end
    end

    # we’re going to keep Sandbox open while Apply is closed irl, but we don’t want
    # to set short inactive dates due to the proximity of the deadline when
    # we're using the cycle switcher
    specify 'proximity to the deadline is ignored on Sandbox', :sandbox do
      submitted = '20 Sept 2023 0:00:00 AM BST'
      correct_rbd = '1 Nov 2023 23:59:59 PM GMT'

      travel_temporarily_to(Time.zone.parse(submitted)) do
        expect(calculator.inactive_date).to be_within(1.second).of(Time.zone.parse(correct_rbd))
        expect(calculator.inactive_days).to eq 30
      end
    end
  end
end
