require 'rails_helper'

RSpec.describe SetRejectByDefault do
  describe '#call' do
    it 'does not update dates when nothing changes', :with_audited do
      application_choice = create(:application_choice, sent_to_provider_at: Time.zone.now)

      expect { call_service(application_choice) }.to change { Audited::Audit.where(auditable_type: 'ApplicationChoice').count }.by(1)
      expect { call_service(application_choice) }.not_to change(Audited::Audit.where(auditable_type: 'ApplicationChoice'), :count)
    end
  end

  describe 'RBD calculation' do
    submitted_vs_rbd_dates = [
      ['2 Sept 2019 9:00:00 AM BST', '28 Sep 2019 0:00:00 AM BST', 'near the BST/GMT boundary'],
      ['1 Jul 2019 9:00:00 AM BST',  '30 Jul 2019 0:00:00 AM BST', 'safely within BST'],
      ['4 Jan 2019 11:00:00 PM GMT', '2 Mar 2019 0:00:00 AM GMT',  'safely within GMT'],
      ['1 Jul 2020 11:00:00 PM BST', '30 Jul 2020 0:00:00 AM BST', 'during the 20-day summer period'],
      ['21 Nov 2021 12:00:00 PM GMT', '18 Feb 2022 23:59:59 PM GMT', 'near the Christmas holidays'],
      ['1 Sept 2021 0:00:00 AM BST', '29 Sept 2021 23:59:59 PM BST', '7 days before the apply 1 deadline'],
      ['7 Sept 2021 0:00:00 AM BST', '29 Sept 2021 23:59:59 PM BST', '1 day before apply 1 deadline'],
      ['20 Sept 2021 0:00:00 AM BST', '29 Sep 2021 23:59:59 PM BST', '1 day before apply 2 deadline'],
    ].freeze

    submitted_vs_rbd_dates.each do |submitted, correct_rbd, test_case|
      it "is correct when the application is delivered #{test_case}", continuous_applications: false do
        if test_case == 'near the Christmas holidays'
          pending('RBD rules have changed for this cycle (different holidays). Unsure of the value of these hardcoded dates.')
        end

        travel_temporarily_to(Time.zone.parse(submitted)) do
          choice = create(:application_choice, sent_to_provider_at: Time.zone.now)

          call_service(choice)

          expect(choice.reload.reject_by_default_at).to be_within(1.second).of(Time.zone.parse(correct_rbd))
        end
      end
    end

    # we’re going to keep Sandbox open while Apply is closed irl, but we don’t want
    # to set short RBDs due to the proximity of the deadline when we're using the
    # cycle switcher
    specify 'proximity to the deadline is ignored on Sandbox', :sandbox do
      submitted = '20 Sept 2021 0:00:00 AM BST'
      correct_rbd = '18 Oct 2021 23:59:59 PM BST'

      travel_temporarily_to(Time.zone.parse(submitted)) do
        choice = create(:application_choice, sent_to_provider_at: Time.zone.now)

        call_service(choice)

        expect(choice.reload.reject_by_default_at).to be_within(1.second).of(Time.zone.parse(correct_rbd))
      end
    end
  end

  def call_service(application_choice)
    SetRejectByDefault.new(application_choice).call
  end
end
