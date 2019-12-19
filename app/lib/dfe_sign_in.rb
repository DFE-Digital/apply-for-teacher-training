module DfESignIn
  def self.bypass?
    (HostingEnvironment.review? || Rails.env.development?) && ENV['BYPASS_DFE_SIGN_IN'] == 'true'
  end
end
