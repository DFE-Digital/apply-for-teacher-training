# Our specs forbid parts of the application to use parts from other namespaces,
# which is as it should be.
#
# In very rare circumstances we would like to share code between namespaces.
# This module aliases namespaced code into a neutral, explicit namespace for
# reuse.
module AllowedCrossNamespaceUsage
  VendorAPIApplicationPresenter = VendorAPI::ApplicationPresenter
  RegisterAPISingleApplicationPresenter = RegisterAPI::SingleApplicationPresenter
  VENDOR_API_VERSION = VendorAPI::VERSION
end
