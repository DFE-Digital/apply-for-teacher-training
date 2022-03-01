require 'rails_helper'

RSpec.describe HostingEnvironment do
  describe '.dfe_signup_only?' do
    %w[qa review staging].each do |environment|
      it "returns true for `#{environment}`" do
        ClimateControl.modify HOSTING_ENVIRONMENT_NAME: environment do
          expect(described_class.dfe_signup_only?).to be(true)
        end
      end
    end

    %w[development test sandbox production].each do |environment|
      it "returns false for `#{environment}`" do
        ClimateControl.modify HOSTING_ENVIRONMENT_NAME: environment do
          expect(described_class.dfe_signup_only?).to be(false)
        end
      end
    end
  end
end
