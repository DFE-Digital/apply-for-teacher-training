require 'rails_helper'

RSpec.describe EflYearValidator do
  let(:award_year) { nil }

  before do
    %w[IeltsForm OtherEflQualificationForm ToeflForm].map do |form|
      stub_const(form.camelcase.to_s, Class.new).class_eval do
        include ActiveModel::Validations
        include ActiveModel::Model

        attr_accessor :award_year

        validates :award_year, efl_year: true
      end
    end
  end

  describe 'is valid' do
    %w[IeltsForm OtherEflQualificationForm ToeflForm].map do |model|
      context 'when year is nil' do
        it 'returns no error' do
          expect(model.constantize.new(award_year: award_year)).to be_valid
        end
      end

      context 'when year is in the correct format' do
        let(:award_year) { Time.zone.now.year.to_s }

        it 'returns no error' do
          expect(model.constantize.new(award_year: award_year)).to be_valid
        end
      end

      context 'when year is valid for all forms' do
        let(:award_year) { '1981' }

        it 'returns no error' do
          expect(model.constantize.new(award_year: award_year)).to be_valid
        end
      end
    end
  end

  describe 'form errors' do
    %w[IeltsForm OtherEflQualificationForm ToeflForm].map do |model|
      let(:form) do
        "CandidateInterface::EnglishForeignLanguage::#{model}".constantize.new(award_year: award_year)
      end

      context 'when year is not a number' do
        let(:award_year) { 'A950' }

        it 'returns a not_a_year error' do
          expect(form.valid?).to be_falsey
          expect(form.errors[:award_year]).to contain_exactly(I18n.t("activemodel.errors.models.candidate_interface/english_foreign_language/#{model.underscore}.attributes.award_year.not_a_year"))
        end
      end

      context 'when year is outside the acceptable start date for all forms' do
        let(:award_year) { '1899' }

        it 'returns an invalid error' do
          expect(form.valid?).to be_falsey
          expect(form.errors[:award_year]).to contain_exactly(I18n.t("activemodel.errors.models.candidate_interface/english_foreign_language/#{model.underscore}.attributes.award_year.invalid"))
        end
      end

      context 'when year is in future' do
        let(:award_year) { '2030' }

        it 'returns a future error' do
          expect(form.valid?).to be_falsey
          expect(form.errors[:award_year]).to contain_exactly(I18n.t("activemodel.errors.models.candidate_interface/english_foreign_language/#{model.underscore}.attributes.award_year.future"))
        end
      end
    end
  end

  describe 'valid and invalid years depending on form' do
    context 'when year is valid for other efl qualifications' do
      let(:award_year) { '1901' }

      it 'is valid' do
        expect(OtherEflQualificationForm.new(award_year: award_year).valid?).to be_truthy
      end

      it 'is invalid' do
        expect(IeltsForm.new(award_year: award_year).valid?).to be_falsey
        expect(ToeflForm.new(award_year: award_year).valid?).to be_falsey
      end
    end

    context 'when year is valid for toefl and other efl qualifications' do
      let(:award_year) { '1979' }

      it 'is valid' do
        expect(OtherEflQualificationForm.new(award_year: award_year).valid?).to be_truthy
        expect(ToeflForm.new(award_year: award_year).valid?).to be_truthy
      end

      it 'is invalid' do
        expect(IeltsForm.new(award_year: award_year).valid?).to be_falsey
      end
    end
  end
end
