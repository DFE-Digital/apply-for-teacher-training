require 'rails_helper'

RSpec.describe UpdateDuplicateMatches do
  let(:candidate1) { create(:candidate) }
  let(:candidate2) { create(:candidate) }
  let!(:application_form) do
    create(:application_form, candidate: candidate1, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
  end
  let!(:duplicate_application_form) do
    create(:application_form, candidate: candidate2, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
  end

  describe '#save!' do
    it 'creates a resolved duplicate match with both candidates' do
      described_class.new(application_form).save!

      match = DuplicateMatch.sole
      expect(match).to have_attributes(
        last_name: 'Thompson',
        date_of_birth: Date.new(1996, 1, 1),
        postcode: 'W6 9BH',
        recruitment_cycle_year: current_year,
        resolved: true,
      )
      expect(match.candidates).to contain_exactly(candidate1, candidate2)
    end

    it 'emails the original account' do
      expect { described_class.new(application_form).save! }
        .to have_enqueued_mail(CandidateMailer, :duplicate_match_original_account_email).with(application_form)
    end

    it 'emails the duplicate account' do
      expect { described_class.new(application_form).save! }
        .to have_enqueued_mail(CandidateMailer, :duplicate_match_email).with(duplicate_application_form)
    end

    it 'does not send the duplicate email to the original account' do
      expect { described_class.new(application_form).save! }
        .not_to have_enqueued_mail(CandidateMailer, :duplicate_match_email).with(application_form)
    end

    it 'locks only the duplicate account' do
      described_class.new(application_form).save!

      expect(candidate1.reload.account_locked).to be(false)
      expect(candidate2.reload.account_locked).to be(true)
    end

    it 'does not block submission' do
      described_class.new(application_form).save!

      expect(candidate1.reload.submission_blocked).to be(false)
      expect(candidate2.reload.submission_blocked).to be(false)
    end

    context 'when the duplicate match already exists' do
      before do
        described_class.new(application_form).save!
      end

      it 'reuses the existing duplicate match' do
        expect { described_class.new(application_form).save! }.not_to change(DuplicateMatch, :count)
      end

      it 'does not email the existing duplicate again' do
        expect { described_class.new(application_form).save! }
          .not_to have_enqueued_mail(CandidateMailer, :duplicate_match_email)
      end

      it 'does not email the original account again' do
        expect { described_class.new(application_form).save! }
          .not_to have_enqueued_mail(CandidateMailer, :duplicate_match_original_account_email)
      end

      context 'when a new duplicate account is created' do
        let(:candidate3) { create(:candidate) }
        let!(:new_application_form) do
          create(:application_form, candidate: candidate3, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
        end

        it 'adds the new candidate to the existing match' do
          described_class.new(new_application_form).save!

          expect(DuplicateMatch.sole.candidates).to contain_exactly(candidate1, candidate2, candidate3)
        end

        it 'emails only the new duplicate account' do
          expect { described_class.new(new_application_form).save! }
            .to have_enqueued_mail(CandidateMailer, :duplicate_match_email).with(new_application_form).once
        end

        it 'emails the original account about the new duplicate' do
          expect { described_class.new(new_application_form).save! }
            .to have_enqueued_mail(CandidateMailer, :duplicate_match_original_account_email).with(application_form).once
        end

        it 'locks the new duplicate account' do
          described_class.new(new_application_form).save!

          expect(candidate3.reload.account_locked).to be(true)
        end
      end
    end

    context 'when the candidate no longer matches anyone' do
      before do
        described_class.new(application_form).save!
        application_form.update!(postcode: 'SW1A 1AA')
      end

      it 'keeps the candidates in the match and touches it' do
        match = DuplicateMatch.sole

        travel_temporarily_to(1.hour.from_now) do
          expect { described_class.new(application_form).save! }.to(change { match.reload.updated_at })
        end

        expect(candidate1.reload.duplicate_match).to eq(match)
        expect(candidate2.reload.duplicate_match).to eq(match)
      end

      it 'does not send emails' do
        expect { described_class.new(application_form).save! }.not_to have_enqueued_mail
      end
    end

    context 'when there are no matching application forms' do
      before do
        duplicate_application_form.update!(postcode: 'SW1A 1AA')
      end

      it 'does not create a duplicate match' do
        expect { described_class.new(application_form).save! }.not_to change(DuplicateMatch, :count)
      end

      it 'does not send emails' do
        expect { described_class.new(application_form).save! }.not_to have_enqueued_mail
      end

      it 'does not lock any accounts' do
        described_class.new(application_form).save!

        expect(candidate1.reload.account_locked).to be(false)
        expect(candidate2.reload.account_locked).to be(false)
      end
    end
  end
end
