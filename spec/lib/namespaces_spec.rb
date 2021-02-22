require 'rails_helper'

RSpec.describe 'Namespace' do
  namespaces = %w[CandidateInterface ProviderInterface SupportInterface APIDocs RefereeInterface VendorAPI UCASMatching DataAPI]

  namespaces.each do |namespace|
    describe namespace.constantize do
      (namespaces - [namespace]).each do |other_namespace|
        it "does not use code from the #{other_namespace} namespace" do
          command = "grep -rnw app/**/#{namespace.underscore} -e '#{other_namespace}'"
          usage_of_namespaced_code_in_other_namespace = `#{command}`
          expect(usage_of_namespaced_code_in_other_namespace).to be_empty, usage_of_namespaced_code_in_other_namespace
        end
      end
    end
  end
end
