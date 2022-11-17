require 'rails_helper'

RSpec.describe StatsSummary do
  it 'generates correct stats' do
    create(:application_form, submitted_at: 1.minute.ago)
    create(:application_choice, :with_recruited)
    create(:application_choice, :with_offer)
    create(:application_choice, :with_rejection)
    create(:application_choice, :with_rejection_by_default)

    travel_temporarily_to(1.year.ago) do
      last_cycle_form = create(:application_form)
      create(:application_choice, :with_recruited, application_form: last_cycle_form)
      create(:application_choice, :with_offer, application_form: last_cycle_form)
      create(:application_choice, :with_rejection, application_form: last_cycle_form)
      create(:application_choice, :with_rejection)
      create(:application_choice, :with_offer)
    end

    output = described_class.new.as_slack_message

    expect(output).to match(/5 candidate signups | 3 last cycle/)
    expect(output).to match(/5 applications begun | 3 last cycle/)
    expect(output).to match(/1 application submitted | 0 last cycle/)
    expect(output).to match(/1 candidate recruited | 1 last cycle/)
    expect(output).to match(/2 offers made | 3 last cycle/)
    expect(output).to match(/2 rejections issued/)
    expect(output).to match(/of which 1 was RBD | 2 last cycle/)
  end
end
