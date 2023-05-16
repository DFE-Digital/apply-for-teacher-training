require 'rails_helper'

RSpec.describe SupportInterface::OfferConditionsExport do
  describe 'documentation' do
    before do
      create(:application_choice, :offered)
    end

    it_behaves_like 'a data export'
  end

  describe '#offers' do
    it 'returns all application choices that have had an offer' do
      # excluded
      create(:completed_application_form, application_choices_count: 1)
      create(:application_choice, :awaiting_provider_decision)
      create(:application_choice, :rejected)
      # included
      create(:application_choice, :offered)
      create(:application_choice, :offered, :course_changed)
      create(:application_choice, :accepted)
      create(:application_choice, :declined)
      create(:application_choice, :declined_by_default)
      create(:application_choice, :offer_withdrawn)
      create(:application_choice, :recruited)
      create(:application_choice, :offer_deferred)
      create(:application_choice, :offered, :previous_year)

      offers = described_class.new.offers
      expect(offers.count).to eq(9)
    end

    it 'returns a support reference for each application choice with an offer' do
      form = create(:completed_application_form)
      create(:application_choice, :declined, application_form: form)
      create(:application_choice, :accepted, application_form: form)
      create(:application_choice, :withdrawn, application_form: form)

      support_references = described_class.new.offers.map { |o| o[:support_reference] }
      expect(support_references).to eq([form.support_reference] * 2)
    end

    it 'returns phase information for each offer' do
      unsuccessful_application_choices = [create(:application_choice, :declined),
                                          create(:application_choice, :withdrawn)]
      apply_1_form = create(:completed_application_form,
                            application_choices: unsuccessful_application_choices)
      apply_2_form = ApplyAgain.new(apply_1_form).call
      create(:application_choice, :offered, application_form: apply_2_form)

      phases = described_class.new.offers.map { |o| o[:phase] }
      expect(phases).to eq(%w[apply_1 apply_2])
    end

    it 'contains qualification information' do
      form = create(:completed_application_form, :with_degree_and_gcses)
      create(:application_choice, :offered, application_form: form)
      offers = described_class.new.offers

      qualification_types = offers.map { |o| o[:qualification_type] }
      expect(qualification_types.first).to include('gcse, gcse, gcse')
      expect(qualification_types.first).to include('degree')

      qualification_subjects = offers.map { |o| o[:qualification_subject] }
      expect(qualification_subjects.first.downcase).to include('maths')
      expect(qualification_subjects.first.downcase).to include('english')
      expect(qualification_subjects.first.downcase).to include('science')

      qualification_grades = offers.map { |o| o[:qualification_grade] }
      expected_grades = form.application_qualifications.order(:created_at, :id).map(&:grade).join(', ')
      expect(qualification_grades.first).to eq(expected_grades)

      start_years = offers.map { |o| o[:start_year] }
      expected_years = form.application_qualifications.order(:created_at, :id).map(&:start_year).join(', ')
      expect(start_years.first).to eq(expected_years)

      award_years = offers.map { |o| o[:award_year] }
      expected_years = form.application_qualifications.order(:created_at, :id).map(&:award_year).join(', ')
      expect(award_years.first).to eq(expected_years)
    end

    it 'returns provider information for each offer' do
      choice = create(:application_choice, :offered)

      offers = described_class.new.offers
      expect(offers.first[:provider_code]).to eq(choice.provider.code)
      expect(offers.first[:provider_name]).to eq(choice.provider.name)
    end

    it 'returns original course information for each offer' do
      choice = create(:application_choice, :offered, :course_changed)

      offers = described_class.new.offers
      expect(offers.first[:course_code]).to eq(choice.course.code)
      expect(offers.first[:course_name]).to eq(choice.course.name)
      expect(offers.first[:course_location]).to eq(choice.site.name)
      expect(offers.first[:course_study_mode]).to eq(choice.course_option.study_mode)
    end

    describe 'offer_changed' do
      it 'returns true if the course has been changed' do
        create(:application_choice, :course_changed_after_offer)

        offers = described_class.new.offers
        expect(offers.first[:offer_changed]).to be true
      end

      it 'returns false if the course has not been changed' do
        create(:application_choice, :offered)

        offers = described_class.new.offers
        expect(offers.first[:offer_changed]).to be false
      end
    end

    it 'returns offered course information' do
      choice = create(:application_choice, :offered)

      offers = described_class.new.offers

      expect(offers.first[:offered_provider_code]).to eq(choice.current_provider.code)
      expect(offers.first[:offered_provider_name]).to eq(choice.current_provider.name)
      expect(offers.first[:offered_course_name]).to eq(choice.current_course.name)
      expect(offers.first[:offered_course_code]).to eq(choice.current_course.code)
      expect(offers.first[:offered_course_location]).to eq(choice.current_site.name)
      expect(offers.first[:offered_course_study_mode]).to eq(choice.current_course_option.study_mode)
    end

    it 'returns most recent offered_at' do
      choice = create(:application_choice, :offered, :course_changed)

      offers = described_class.new.offers
      expect(offers.first[:offer_made_at]).to eq(choice.offered_at.iso8601)
    end

    it 'includes offer conditions' do
      choice = create(:application_choice, :offered)
      choice.offer.conditions = [build(:text_condition, description: 'DBS Check'), build(:text_condition, description: 'Be cool')]
      choice.offer.save

      offers = described_class.new.offers
      expect(offers.first[:conditions]).to eq('DBS Check, Be cool')
    end
  end
end
