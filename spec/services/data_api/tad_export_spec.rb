require 'rails_helper'

RSpec.describe DataAPI::TADExport do
  before do
    create(:submitted_application_choice, :with_completed_application_form, status: 'rejected', rejected_by_default: true)
    create(:submitted_application_choice, :with_completed_application_form, status: 'declined', declined_by_default: true)
    create(:submitted_application_choice, :with_completed_application_form, status: 'rejected')
    create(:submitted_application_choice, :with_completed_application_form, status: 'declined')
  end

  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'incorporates RDB and DBD into the status' do
      result = described_class.new.data_for_export

      expect(result.map { |r| r[:status] }).to match_array(%w[rejected_by_default declined_by_default rejected declined])
    end
  end

  it 'returns deferred applications which have been reinstated in the current cycle' do
    choice = create(:submitted_application_choice, :with_completed_application_form, :with_deferred_offer, :previous_year_but_still_available)

    result = described_class.new.data_for_export
    expect(result.count).to eq 4

    # necessary to reconfirm the offer
    support_user = create(:support_user)

    # we roll the course_option from :previous_year to the current cycle, which is the "next" cycle from its POV
    ReinstateConditionsMet.new(actor: support_user, application_choice: choice, course_option: choice.course_option.in_next_cycle).save

    result = described_class.new.data_for_export
    expect(result.count).to eq 5
  end
end
