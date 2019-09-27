class MagicLinkStrategy < Warden::Strategies::Base
  MAX_TOKEN_DURATION = 1.hour

  def valid?
    params[:token].present?
  end

  def authenticate!
    candidate = FindCandidateByToken.call(raw_token: params[:token])

    if candidate.present? && token_not_expired?(candidate)
      success!(candidate)
    else
      fail!
    end
  end

  private

  def token_not_expired?(candidate)
    Time.now < (candidate.magic_link_token_sent_at + MAX_TOKEN_DURATION)
  end
end
