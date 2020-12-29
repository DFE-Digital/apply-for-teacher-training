require 'rails_helper'

RSpec.describe AuthenticationToken do
  describe '#still_valid?' do
    it 'is valid if it has not expired or been used' do
      authentication_token = create(
        :authentication_token,
        created_at: Time.zone.now - AuthenticationToken::MAX_TOKEN_DURATION + 1.minute,
      )
      expect(authentication_token.still_valid?).to eql(true)
    end

    it 'is invalid if it has been saved' do
      authentication_token = build(
        :authentication_token,
      )
      expect(authentication_token.still_valid?).to eql(false)
    end

    it 'is invalid if it has not expired but has been used' do
      authentication_token = create(
        :authentication_token,
        created_at: Time.zone.now - AuthenticationToken::MAX_TOKEN_DURATION + 1.minute,
        used_at: 1.minute.ago,
      )
      expect(authentication_token.still_valid?).to eql(false)
    end

    it 'is invalid if it has not been used but has expired' do
      authentication_token = create(
        :authentication_token,
        created_at: Time.zone.now - AuthenticationToken::MAX_TOKEN_DURATION - 1.minute,
      )
      expect(authentication_token.still_valid?).to eql(false)
    end
  end
end
