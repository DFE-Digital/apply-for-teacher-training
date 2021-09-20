require 'rails_helper'

RSpec.describe StatsSummary do
  it 'generates correct stats' do
    create(:application_form, submitted_at: 1.minute.ago)
    create(:application_choice, :with_recruited)
    create(:application_choice, :with_offer)
    create(:application_choice, :with_rejection)
    create(:application_choice, :with_rejection_by_default)

    output = described_class.new.as_slack_message

    expect(output).to match(/1 application submitted/)
    expect(output).to match(/1 candidate recruited/)
    expect(output).to match(/2 offers made/)
    expect(output).to match(/2 rejections issued/)
    expect(output).to match(/of which 1 was RBD/)
  end
end
