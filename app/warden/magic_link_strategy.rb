class MagicLinkStrategy < Warden::Strategies::Base
  def valid?
    params[:token].present?
  end

  def authenticate!
    candidate = FindCandidateByToken.call(raw_token: params[:token])

    if FindCandidateByToken.token_not_expired?(candidate)
      success!(candidate)
    else
      fail!
    end
  end
end
