require 'rails_helper'

RSpec.describe SupportInterface::PersonaUserComponent do
  let(:persona_type) { :self_ratified_user }
  let(:render) { render_inline(described_class.new(persona_type)) }

  context 'when the persona user does not exist' do
    it 'does not render' do
      expect(render.text).to be_empty
    end
  end

  context 'when the persona user exists' do
    let!(:persona_user) do
      dsi_uid = I18n.t("personas.users.#{persona_type}.uid")
      create(:provider_user, dfe_sign_in_uid: dsi_uid)
    end

    it 'renders the user’s full name' do
      expect(render.css('h2').text.squish).to eq(persona_user.full_name)
    end

    it 'shows a button to sign in as the user' do
      expect(render.css('.govuk-button').first.text).to eq("Sign in as #{persona_user.full_name}")
    end

    it 'shows a tag with the organisation membership type' do
      expect(render.css('.govuk-tag--blue').text).to eq('Self ratified')
    end

    it 'shows a tag with the user type' do
      expect(render.css('.govuk-tag--green').text).to eq('User')
    end
  end
end
