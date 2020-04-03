# Fix IRB deprecation warning on tab-completion.
#
# Backports the fix for https://github.com/rails/rails/issues/37097
# from https://github.com/rails/rails/pull/37100
#
# Backports proposed fix for https://github.com/rails/rails/pull/37468
# from https://github.com/rails/rails/pull/37468
module ActiveSupportBackports
  warn "[DEPRECATED] #{self} should no longer be needed. Please remove!" if Rails.version >= '6.1'

  def self.prepended(base)
    base.class_eval do
      delegate :hash, :instance_methods, :respond_to?, to: :target
    end
  end
end

module ActiveSupport
  class Deprecation
    class DeprecatedConstantProxy
      prepend ActiveSupportBackports
    end
  end
end
