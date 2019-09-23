class MagicLinkStrategy < Warden::Strategies::Base
  def valid?
    params[:token].present?
  end

  def authenticate!
    candidate = FindCandidateByToken.call(raw_token: params[:token])

    if candidate
      success!(candidate)
    else
      fail!
    end
  end
end
