require 'rails_helper'

RSpec.describe DataMigrations::BackfillWithdrawalReasons do
  context 'where choice has multiple valid withdrawal reasons' do
    it 'maps the old reasons to the new reasons' do
      application_choice = create(:application_choice, :withdrawn, structured_withdrawal_reasons: all_old_reasons)
      described_class.new.change
      expect(application_choice.reload.structured_withdrawal_reasons).to eq(all_new_reasons)
    end

    it 'does not update any other fields' do
      time_attributes = %w[withdrawn_at sent_to_provider_at created_at updated_at]
      application_choice = create(:application_choice, :withdrawn, structured_withdrawal_reasons: all_old_reasons)
      old_attributes = application_choice.attributes

      advance_time_by(1.hour)

      described_class.new.change
      new_attributes = application_choice.reload.attributes

      time_attributes.each do |key|
        expect(old_attributes[key]).to be_within(0.5.seconds).of(new_attributes[key])
      end

      [old_attributes, new_attributes].each do |attributes|
        [*time_attributes, 'structured_withdrawal_reasons'].each do |key|
          attributes.delete(key)
        end
      end

      expect(old_attributes).to match(new_attributes)
    end

    it 'does not create new records' do
      create_list(:application_choice, 3)
      create_list(:application_choice, 3,
                  :withdrawn,
                  structured_withdrawal_reasons: %w[flexibile_itt_study_intensity flexible_itt_course_date])
      described_class.new.change

      expect(ApplicationChoice.count).to eq(6)
    end
  end

  context 'where choice has some invalid withdrawal reasons' do
    it 'discards to the invalid reason, and maps the valid ones to the new choices' do
      application_choice = create(:application_choice, :withdrawn, structured_withdrawal_reasons: %w[costs something_else])
      described_class.new.change
      expect(application_choice.reload.structured_withdrawal_reasons).to eq(['concerns_about_cost'])
    end
  end

  context 'where choice does not have any withdrawal reasons' do
    it 'does not change the structured withdrawal reasons' do
      application_choice = create(:application_choice, :withdrawn, structured_withdrawal_reasons: [])
      described_class.new.change
      expect(application_choice.reload.structured_withdrawal_reasons).to eq([])
    end

    it 'does not change records where reasons are nil' do
      application_choice = create(:application_choice, :withdrawn, structured_withdrawal_reasons: nil)
      described_class.new.change
      expect(application_choice.reload.structured_withdrawal_reasons).to be_nil
    end
  end

  def all_old_reasons
    # Yes, flexible is spelled incorrectly in one of the old reasons, flexibile_itt_study_intensity
    %w[application_unsuccessful change_of_course_option change_of_training_provider circumstances_changed costs
       course_location course_unavailable deferred flexibile_itt_study_intensity flexible_itt_course_date
       flexible_itt_disabilities provider_behaviour]
  end

  def all_new_reasons
    %w[asked_to_withdraw applying_to_different_course_same_provider applying_to_different_provider
       no_longer_want_to_train_to_teach concerns_about_cost training_location_too_far_away course_not_available_anymore
       applying_to_teacher_training_next_year concerns_about_time_to_train wait_to_start_course_too_long
       concerns_about_training_with_disability_or_health_condition training_provider_has_not_responded]
  end
end
