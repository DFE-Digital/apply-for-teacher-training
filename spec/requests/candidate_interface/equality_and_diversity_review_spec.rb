require 'rails_helper'

RSpec.describe 'PUT candidate/application/equality-and-diversity' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }
  let(:paths) do
    %w[
      candidate_interface_sex_path
      candidate_interface_disabilities_path
      candidate_interface_ethnic_background_path
    ]
  end

  before do
    sign_in candidate
    create(:completed_application_form, :with_completed_references, :with_equality_and_diversity_data, :eligible_for_free_school_meals, candidate:)
  end

  context 'when changing an answer from review page', time: mid_cycle do
    it 'redirects to the review page' do
      paths.each do |path|
        patch public_send(path, return_to: :review), params: { candidate_interface_equality_and_diversity_sex_form: { sex: 'female' }, candidate_interface_equality_and_diversity_disabilities_form: { disabilities: ['Other'] }, candidate_interface_equality_and_diversity_ethnic_background_form: { ethnic_background: 'Roma' } }
        expect(response).to redirect_to(candidate_interface_review_equality_and_diversity_path)
      end
    end
  end

  context 'when changing an answer from the equality flow', time: mid_cycle do
    it 'does not redirect to review page' do
      paths.each do |path|
        patch public_send(path), params: { candidate_interface_equality_and_diversity_sex_form: { sex: 'female' }, candidate_interface_equality_and_diversity_disabilities_form: { disabilities: ['Other'] }, candidate_interface_equality_and_diversity_ethnic_background_form: { ethnic_background: 'Roma' }, candidate_interface_equality_and_diversity_free_school_meals_form: { free_school_meals: 'Yes' } }
        expect(response).not_to redirect_to(candidate_interface_review_equality_and_diversity_path)
      end
    end
  end
end
