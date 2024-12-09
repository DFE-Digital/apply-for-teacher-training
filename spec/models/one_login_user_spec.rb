require 'rails_helper'

RSpec.describe OneLoginUser do
  subject(:authentificate) { one_login_user.authentificate }

  let(:one_login_user) { described_class.new(omniauth_object) }
  let(:omniauth_object) do
    OmniAuth::AuthHash.new(
      {
        uid: '123',
        info: {
          email: 'test@email.com',
        },
      },
    )
  end

  describe 'authentificate' do
    it 'authentificates successfuly using the token' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: '123')

      expect { authentificate }.to not_change(
        candidate.reload.one_login_auth,
        :id,
      )

      expect(authentificate).to eq(candidate)
    end

    it 'authentificates successfuly using the email and creates a one_login_auth' do
      candidate = create(:candidate, email_address: 'test@email.com')

      expect { authentificate }.to change {
        candidate.reload.one_login_auth.present?
      }.from(false).to(true)

      expect(authentificate).to eq(candidate)
      expect(authentificate.one_login_auth).to have_attributes(
        email_address: authentificate.email_address,
        token: '123',
      )
    end

    it "authentificates successfuly and creates a candidate if we can't find one" do
      expect { authentificate }.to change(
        Candidate,
        :count,
      ).by(1)

      expect(authentificate).to eq(Candidate.last)
      expect(authentificate.one_login_auth).to have_attributes(
        email_address: authentificate.email_address,
        token: '123',
      )
    end

    it 'raises error if the candidate already has a different one login token' do
      candidate = create(:candidate, email_address: 'test@email.com')
      create(:one_login_auth, candidate:, token: '456')

      expect { authentificate }.to raise_exception(OneLoginUser::Error).with_message(
        "Candidate #{candidate.id} has a different one login " \
        'token than the user trying to login. Token used to auth 123',
      )
    end
  end
end
