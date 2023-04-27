require 'rails_helper'

RSpec.describe DataMigrations::ModifyDigitalEmailAddresses do
  let!(:support_users) do
    [
      create(:support_user, email_address: 'kuldip@digital.education.gov.uk'),
      create(:support_user, email_address: 'sanjeema@digital.education.gov.uk'),
      create(:support_user, email_address: 'prakash@education.gov.uk'),
    ]
  end

  it "updates support users' @digital email addresses to their @education equivalents" do
    described_class.new.change

    expect(support_users.map(&:reload).map(&:email_address)).to eq([
      'kuldip@education.gov.uk',
      'sanjeema@education.gov.uk',
      'prakash@education.gov.uk',
    ])
  end
end
