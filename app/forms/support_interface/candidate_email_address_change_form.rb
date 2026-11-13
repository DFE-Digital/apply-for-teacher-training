module SupportInterface
  class CandidateEmailAddressChangeForm
    include ActiveModel::Model

    attr_accessor :match_id, :email_address, :other_email_address, :candidate_id

    validates :email_address, presence: true
    validates :candidate_id, presence: true
    validates :match_id, presence: true
    validates :other_email_address, presence: true, if: :other_email_address_entered?
    validate :valid_updatable_candidate_email

    def update!
      return false unless valid?

      ActiveRecord::Base.transaction do
        if candidate_with_email_address.present?
          original_email_address = candidate.email_address

          candidate_with_email_address.update!(email_address: dummy_email_address)
          candidate.update!(email_address: updatable_candidate_email)
          candidate_with_email_address.update!(email_address: original_email_address)
        else
          candidate.update!(email_address: updatable_candidate_email)
        end
      end
    end

  private

    def other_email_address_entered?
      @other_email_address_entered ||= email_address == 'other'
    end

    def valid_updatable_candidate_email
      return unless other_email_address_entered?
      return if candidate_with_email_address.present?

      if Candidate.where.not(id: candidate.id).exists?(email_address: updatable_candidate_email)
        errors.add(:other_email_address, 'This email address is already linked to another active account.')
      end
    end

    def updatable_candidate_email
      if other_email_address_entered?
        other_email_address
      else
        email_address
      end
    end

    def dummy_email_address
      @dummy_email_address ||= "#{candidate_id}_to_#{candidate_with_email_address&.id || 'new_email_address'}@example.com"
    end

    def match
      @match ||= DuplicateMatch.find(match_id)
    end

    def candidate
      @candidate ||= match.candidates.find(candidate_id)
    end

    def candidate_with_email_address
      return @candidate_with_email_address if defined?(@candidate_with_email_address)

      @candidate_with_email_address = match.candidates.where(account_locked: true).find_by(email_address: updatable_candidate_email)
    end
  end
end
