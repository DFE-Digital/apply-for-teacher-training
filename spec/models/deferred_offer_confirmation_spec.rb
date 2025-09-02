require 'rails_helper'

RSpec.describe DeferredOfferConfirmation do
  describe 'associations' do
    it { is_expected.to belong_to(:provider_user) }
    it { is_expected.to belong_to(:offer) }
    it { is_expected.to belong_to(:course).optional }
    it { is_expected.to belong_to(:location).optional.class_name('Site') }
  end

  describe 'enums' do
    subject(:deferred_offer_confirmation) { build(:deferred_offer_confirmation) }

    it {
      expect(deferred_offer_confirmation).to define_enum_for(:study_mode)
                          .with_values(
                            full_time: 'full_time',
                            part_time: 'part_time',
                          )
                          .backed_by_column_of_type(:string)
                          .validating(allowing_nil: true)
                          .without_instance_methods
                          .without_scopes
    }

    it {
      expect(deferred_offer_confirmation).to define_enum_for(:conditions_status)
                          .with_values(
                            met: 'met',
                            pending: 'pending',
                          )
                          .backed_by_column_of_type(:string)
                          .validating(allowing_nil: true)
                          .without_instance_methods
                          .without_scopes
    }
  end
end
