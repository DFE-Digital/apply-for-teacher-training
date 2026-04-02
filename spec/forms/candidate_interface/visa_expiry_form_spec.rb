require 'rails_helper'

module CandidateInterface
  RSpec.describe VisaExpiryForm, type: :model do
    subject(:form) do
      described_class.new(application_form)
    end
    let(:application_form) { create(:application_form) }

    describe 'validations' do
      context 'when visa_expired_at is nil' do
        let(:application_form) { build(:application_form, visa_expired_at: nil) }

        it 'is invalid' do
          expect(form.valid?).to be(false)
          expect(form.errors[:visa_expired_at]).to contain_exactly('Enter a visa expiry date')
        end
      end

      context 'when visa_expired_day is invalid' do
        let(:application_form) { build(:application_form) }

        it 'is invalid' do
          form.visa_expired_day = ''
          form.visa_expired_month = 12
          form.visa_expired_year = 2005

          expect(form.valid?).to be(false)
          expect(form.errors[:visa_expired_at]).to contain_exactly('Enter the day when your visa will expire')
        end
      end

      context 'when visa_expired_month is invalid' do
        let(:application_form) { build(:application_form) }

        it 'is invalid' do
          form.visa_expired_day = 1
          form.visa_expired_month = ''
          form.visa_expired_year = 2005

          expect(form.valid?).to be(false)
          expect(form.errors[:visa_expired_at]).to contain_exactly('Enter the month when your visa will expire')
        end
      end

      context 'when visa_expired_year is invalid' do
        let(:application_form) { build(:application_form) }

        it 'is invalid' do
          form.visa_expired_day = 1
          form.visa_expired_month = 12
          form.visa_expired_year = ''

          expect(form.valid?).to be(false)
          expect(form.errors[:visa_expired_at]).to contain_exactly('Enter the year when your visa will expire')
        end
      end

      context 'when visa_expired_at is in the past' do
        let(:application_form) { build(:application_form) }

        it 'is invalid' do
          form.visa_expired_day = 1
          form.visa_expired_month = 12
          form.visa_expired_year = 2005

          expect(form.valid?).to be(false)
          expect(form.errors[:visa_expired_at]).to contain_exactly('Enter a visa expiry date that is in the future')
        end
      end
    end

    describe '#save' do
      it 'saves visa_expred_at on application_form' do
        visa_expired_at = 1.year.from_now
        form.visa_expired_day = visa_expired_at.day
        form.visa_expired_month = visa_expired_at.month
        form.visa_expired_year = visa_expired_at.year

        expected_date = Time.zone.local(
          visa_expired_at.year,
          visa_expired_at.month,
          visa_expired_at.day,
        )

        expect { form.save }.to change { application_form.visa_expired_at }.to(expected_date)
      end

      context 'with invalid form' do
        let(:application_form) { build(:application_form) }

        it 'returns nil' do
          form.visa_expired_day = nil

          expect(form.save).to be_nil
        end
      end
    end
  end
end
