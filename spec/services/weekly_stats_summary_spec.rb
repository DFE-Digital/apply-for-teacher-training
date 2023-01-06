require 'rails_helper'

RSpec.describe WeeklyStatsSummary do
  it 'posts the correct stats' do
    create(:application_form, submitted_at: 1.minute.ago)
    apply_again_application = create(:application_form, phase: 'apply_2')
    create(:application_choice, :with_recruited)
    create(:application_choice, :with_offer)
    create(:application_choice, :with_rejection)
    create(:application_choice, :accepted, accepted_at: 1.minute.ago)
    create(:application_choice, :accepted, accepted_at: 1.minute.ago)
    create(:application_choice, :with_rejection_by_default)
    create(:application_choice, :with_offer, application_form: apply_again_application)

    travel_temporarily_to(CycleTimetable.this_day_last_cycle) do
      last_cycle_form = create(:application_form)
      create(:application_choice, :with_recruited, application_form: last_cycle_form)
      create(:application_choice, :with_offer, application_form: last_cycle_form)
      create(:application_choice, :with_rejection, application_form: last_cycle_form)
      create(:application_choice, :with_rejection)
      create(:application_choice, :with_offer)
    end

    output = described_class.new.as_slack_message

    expect(output).to match('8 total candidate signups \\| This point last cycle we had 3')
    expect(output).to match('7 total initial applications begun \\| This point last cycle we had 3')
    expect(output).to match('1 total Apply again application begun \\| This point last cycle we had 0')
    expect(output).to match('6 total applications submitted \\| This point last cycle we had 2')
    expect(output).to match('1 total candidate recruited \\| This point last cycle we had 1')
    expect(output).to match('5 total offers made \\| This point last cycle we had 3')
    expect(output).to match('3 total offers accepted \\| This point last cycle we had 1')
    expect(output).to match('2 total rejections issued')
    expect(output).to match('of which 1 was RBD \\| This point last cycle we had 2')
  end
end
