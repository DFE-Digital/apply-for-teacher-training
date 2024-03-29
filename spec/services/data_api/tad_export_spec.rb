require 'rails_helper'

RSpec.describe DataAPI::TADExport do
  before do
    create(
      :application_choice,
      :with_completed_application_form,
      status: 'rejected',
      rejected_by_default: true,
    )
    create(
      :application_choice,
      :with_completed_application_form,
      status: 'declined',
      declined_by_default: true,
    )
    create(
      :application_choice,
      :with_completed_application_form,
      status: 'rejected',
    )
    create(
      :application_choice,
      :with_completed_application_form,
      status: 'declined',
    )
  end

  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'incorporates RDB and DBD into the status' do
      result = described_class.new.data_for_export

      expect(result.map { |r| r[:status] }).to match_array(%w[rejected_by_default declined_by_default rejected declined])
    end
  end

  it 'returns deferred applications which have been reinstated in the current cycle' do
    choice = create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, :offer_deferred, :previous_year_but_still_available)

    result = described_class.new.data_for_export
    expect(result.count).to eq 4

    # necessary to reconfirm the offer
    support_user = create(:support_user)

    # we roll the course_option from :previous_year to the current cycle, which is the "next" cycle from its POV
    ConfirmDeferredOffer.new(actor: support_user,
                             application_choice: choice,
                             course_option: choice.course_option.in_next_cycle,
                             conditions_met: true).save

    result = described_class.new.data_for_export
    expect(result.count).to eq 5
  end

  it 'returns course level for current course' do
    primary_course = create(:course, level: :primary)
    secondary_course = create(:course, level: :secondary)
    create(
      :application_choice,
      :with_completed_application_form,
      status: 'offer',
      course_option: create(:course_option, course: secondary_course),
      current_course_option: create(:course_option, course: primary_course),
    )
    result = described_class.new.data_for_export
    expect(result.find { |application| application[:status] = 'offer' }[:course_level]).to eq('primary')
  end
end
