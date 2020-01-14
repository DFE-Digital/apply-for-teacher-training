require 'rails_helper'

RSpec.describe SupportInterface::SendReferenceEmailForm, type: :model, with_audited: true do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:choice) }

    it 'validates new referee email if chosen to new referee' do
      send_reference_email =  SupportInterface::SendReferenceEmailForm.new(choice: 'new_referee')
      error_message = t('activemodel.errors.models.support_interface/send_reference_email_form.attributes.new_referee_email.blank')

      send_reference_email.validate

      expect(send_reference_email.errors.full_messages_for(:new_referee_email)).to eq(
        ["New referee email #{error_message}"],
      )
    end
  end
end
