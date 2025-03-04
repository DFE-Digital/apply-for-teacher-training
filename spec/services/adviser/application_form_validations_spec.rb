require 'rails_helper'

RSpec.describe Adviser::ApplicationFormValidations, type: :model do
  let(:application_form) { create(:application_form) }
  let(:candidate) { application_form.candidate }

  subject(:validations) { described_class.new(application_form) }

  describe 'validations' do
    it 'needs an email_address' do
      candidate.email_address = nil
      expect(validations).to have_error_on(:email_address)
    end

    it 'needs a first_name' do
      application_form.first_name = nil
      expect(validations).to have_error_on(:first_name)
    end

    it 'needs a last_name' do
      application_form.last_name = nil
      expect(validations).to have_error_on(:last_name)
    end

    it 'needs a date_of_birth' do
      application_form.date_of_birth = nil
      expect(validations).to have_error_on(:date_of_birth)
    end

    it 'needs a phone_number' do
      application_form.phone_number = nil
      expect(validations).to have_error_on(:phone_number)
    end

    it 'needs a country' do
      application_form.country = nil
      expect(validations).to have_error_on(:country)
    end

    it 'needs an applicable_degree' do
      expect(validations).to have_error_on(:applicable_degree_for_adviser)
    end

    it 'does not allow a candidate to sign up for an adviser more than once' do
      application_form.assigned!
      expect(validations).to have_error_on(:adviser_status)
    end

    it 'needs a postcode when the candidate has a domestic address' do
      application_form.postcode = nil
      expect(validations).to have_error_on(:postcode)
    end

    context 'when the candidate has an international address' do
      let(:application_form) { create(:application_form, :international_address) }

      it 'does not need a postcode' do
        application_form.postcode = nil
        expect(validations).not_to have_error_on(:postcode)
      end
    end

    context 'when the candidate has a domestic degree' do
      before do
        create(:degree_qualification,
               :adviser_sign_up_applicable,
               application_form:)
      end

      it { expect(validations.applicable_degree_for_adviser).not_to be_international }

      context 'when the candidate does not have Maths and English GCSEs' do
        it 'has errors on the GCSE fields' do
          expect(validations).to have_error_on(:maths_gcse)
          expect(validations).to have_error_on(:english_gcse)
        end
      end

      context 'when the candidate is missing and is not retaking their Maths and English GCSEs' do
        before do
          create(:gcse_qualification, :missing_and_not_currently_completing, subject: 'maths', application_form:)
          create(:gcse_qualification, :missing_and_not_currently_completing, subject: 'english', application_form:)
        end

        it 'has errors on the GCSE fields' do
          expect(validations).to have_error_on(:maths_gcse)
          expect(validations).to have_error_on(:english_gcse)
        end
      end

      context 'when the candidate is missing but currently retaking their Maths and English GCSEs' do
        before do
          create(:gcse_qualification, :missing_and_currently_completing, subject: 'maths', application_form:)
          create(:gcse_qualification, :missing_and_currently_completing, subject: 'english', application_form:)
        end

        it 'does not have errors on the GCSE fields' do
          expect(validations).not_to have_error_on(:maths_gcse)
          expect(validations).not_to have_error_on(:english_gcse)
        end
      end

      context 'when the application form is valid' do
        let(:application_form) { create(:completed_application_form, :with_degree_and_gcses) }

        it { is_expected.to be_valid }
      end
    end

    context 'when the candidate has an international degree' do
      before do
        create(:non_uk_degree_qualification,
               :adviser_sign_up_applicable,
               application_form:)
      end

      it 'does not need GCSEs' do
        expect(validations).not_to have_error_on(:maths_gcse)
        expect(validations).not_to have_error_on(:english_gcse)
        expect(validations).not_to have_error_on(:science_gcse)
      end

      context 'when the application form is valid' do
        let(:application_form) { create(:completed_application_form) }

        it { is_expected.to be_valid }
        it { expect(validations.applicable_degree_for_adviser).to be_international }
      end
    end
  end

  describe '#applicable_degree' do
    it 'returns nil when there are no qualifications' do
      expect(validations.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes non-degree type qualifications' do
      create(:gcse_qualification, application_form:)
      create(:other_qualification, application_form:)

      expect(validations.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes incomplete degrees' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             :incomplete,
             application_form:)

      expect(validations.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes international degrees without equivalency details' do
      create(:non_uk_degree_qualification,
             :adviser_sign_up_applicable,
             enic_reference: nil,
             application_form:)

      expect(validations.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes domestic degrees do not meet the minimum grade requirements' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             grade: 'Third-class honours',
             application_form:)

      expect(validations.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes degrees that are not an applicable level' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             qualification_level: 'foundation',
             application_form:)

      create(:non_uk_degree_qualification,
             :adviser_sign_up_applicable,
             comparable_uk_degree: 'bachelor_ordinary_degree',
             application_form:)

      expect(validations.applicable_degree_for_adviser).to be_nil
    end

    it 'returns an applicable domestic degree, favouring the degree with the highest grade' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             application_form:,
             grade: 'Upper second-class honours (2:1)')

      first_class_domestic_degree = create(:degree_qualification,
                                           :adviser_sign_up_applicable,
                                           application_form:,
                                           grade: 'First-class honours')

      expect(validations.applicable_degree_for_adviser).to eq(first_class_domestic_degree)
    end

    it 'returns an applicable international degree' do
      applicable_international_degree = create(:non_uk_degree_qualification,
                                               :adviser_sign_up_applicable,
                                               application_form:)

      expect(validations.applicable_degree_for_adviser).to eq(applicable_international_degree)
    end

    it 'returns a domestic degree if there are international degrees as well' do
      first_class_domestic_degree = create(:degree_qualification,
                                           :adviser_sign_up_applicable,
                                           application_form:,
                                           grade: 'First-class honours')

      create(:non_uk_degree_qualification,
             :adviser_sign_up_applicable,
             application_form:)

      expect(validations.applicable_degree_for_adviser).to eq(first_class_domestic_degree)
    end
  end
end
