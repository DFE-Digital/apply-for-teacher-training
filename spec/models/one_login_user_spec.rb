require 'rails_helper'

RSpec.describe OneLoginUser do
  subject(:authenticate) { one_login_user.authenticate_or_create_by }

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

  describe 'authenticate_or_create_by' do
    it 'authenticates successfuly using the token' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: '123')

      expect { authenticate }.to not_change(
        candidate.reload.one_login_auth,
        :id,
      )

      expect(authenticate).to eq(candidate)
    end

    it 'authenticates successfuly using the email and creates a one_login_auth' do
      candidate = create(:candidate, email_address: 'test@email.com')

      expect { authenticate }.to change {
        candidate.reload.one_login_auth.present?
      }.from(false).to(true)

      expect(authenticate).to eq(candidate)
      expect(authenticate.one_login_auth).to have_attributes(
        email_address: authenticate.email_address,
        token: '123',
      )
    end

    it "authenticates successfuly and creates a candidate if we can't find one" do
      expect { authenticate }.to change(
        Candidate,
        :count,
      ).by(1)

      expect(authenticate).to eq(Candidate.last)
      expect(authenticate.one_login_auth).to have_attributes(
        email_address: authenticate.email_address,
        token: '123',
      )
    end

    it 'raises error if the candidate already has a different one login token' do
      candidate = create(:candidate, email_address: 'test@email.com')
      create(:one_login_auth, candidate:, token: '456')

      expect { authenticate }.to raise_exception(OneLoginUser::Error).with_message(
        "Candidate #{candidate.id} has a different one login " \
        'token than the user trying to login. Token used to auth 123',
      )
    end
  end
end
