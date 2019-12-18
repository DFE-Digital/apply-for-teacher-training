module DfESignIn
  def self.bypass?
    !HostingEnvironment.production? && ENV['BYPASS_DFE_SIGN_IN'] == 'true'
  end
end
