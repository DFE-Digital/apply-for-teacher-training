require 'rails_helper'

RSpec.describe SupportInterface::OfferConditionsExport do
  describe '#offers' do
    it 'returns all application choices that have had an offer' do
      # excluded
      create(:completed_application_form, application_choices_count: 1)
      create(:submitted_application_choice)
      create(:application_choice, :with_rejection)
      # included
      create(:application_choice, :with_offer)
      create(:application_choice, :with_modified_offer)
      create(:application_choice, :with_accepted_offer)
      create(:application_choice, :with_declined_offer)
      create(:application_choice, :with_declined_by_default_offer)
      create(:application_choice, :with_withdrawn_offer)
      create(:application_choice, :with_recruited)
      create(:application_choice, :with_deferred_offer)
      create(:application_choice, :with_offer, :previous_year)

      offers = described_class.new.offers
      expect(offers.count).to eq(9)
    end

    it 'returns a support reference for each application choice with an offer' do
      form = create(:completed_application_form)
      create(:application_choice, :with_declined_offer, application_form: form)
      create(:application_choice, :with_accepted_offer, application_form: form)
      create(:application_choice, :withdrawn, application_form: form)

      support_references = described_class.new.offers.map { |o| o[:support_reference] }
      expect(support_references).to eq([form.support_reference] * 2)
    end

    it 'returns phase information for each offer' do
      apply_1_form = create(:completed_application_form)
      create(:application_choice, :with_declined_offer, application_form: apply_1_form)
      create(:application_choice, :withdrawn, application_form: apply_1_form)
      apply_2_form = ApplyAgain.new(apply_1_form).call
      create(:application_choice, :with_offer, application_form: apply_2_form)

      phases = described_class.new.offers.map { |o| o[:phase] }
      expect(phases).to eq(%w[apply_1 apply_2])
    end

    it 'contains qualification information' do
      form = create(:completed_application_form, with_gcses: true, with_degree: true)
      create(:application_choice, :with_offer, application_form: form)
      offers = described_class.new.offers

      qualification_types = offers.map { |o| o[:qualification_type] }
      expect(qualification_types.first).to include('gcse,gcse,gcse')
      expect(qualification_types.first).to include('degree')

      qualification_subjects = offers.map { |o| o[:qualification_subject] }
      expect(qualification_subjects.first).to include('maths,english,science')

      qualification_grades = offers.map { |o| o[:qualification_grade] }
      expected_grades = form.application_qualifications.order(:created_at).map(&:grade).join(',')
      expect(qualification_grades.first).to eq(expected_grades)

      start_years = offers.map { |o| o[:start_year] }
      expected_years = form.application_qualifications.order(:created_at).map(&:start_year).join(',')
      expect(start_years.first).to eq(expected_years)

      award_years = offers.map { |o| o[:award_year] }
      expected_years = form.application_qualifications.order(:created_at).map(&:award_year).join(',')
      expect(award_years.first).to eq(expected_years)
    end

    it 'returns provider information for each offer' do
      choice = create(:application_choice, :with_modified_offer)

      offers = described_class.new.offers
      expect(offers.first[:provider_code]).to eq(choice.provider.code)
      expect(offers.first[:provider]).to eq(choice.provider.name)
    end

    it 'returns offered course information' do
      choice = create(:application_choice, :with_modified_offer)

      offers = described_class.new.offers
      expect(offers.first[:course_offered_provider_name]).to eq(choice.offered_course.provider.name)
      expect(offers.first[:course_offered_course_name]).to eq(choice.offered_course.name)
    end

    it 'returns most recent offered_at' do
      choice = create(:application_choice, :with_modified_offer)

      offers = described_class.new.offers
      expect(offers.first[:offer_made_at]).to eq(choice.offered_at.to_s(:govuk_date))
    end

    it 'includes offer conditions' do
      choice = create(:application_choice, :with_modified_offer)
      choice.update(offer: { 'conditions' => ['DBS Check', 'Be cool'] })

      offers = described_class.new.offers
      expect(offers.first[:conditions]).to eq('DBS Check,Be cool')
    end
  end
end
