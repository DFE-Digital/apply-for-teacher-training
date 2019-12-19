module DfESignIn
  def self.bypass?
    HostingEnvironment.development? && ENV['BYPASS_DFE_SIGN_IN'] == 'true'
  end
end
