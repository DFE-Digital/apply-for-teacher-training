require 'rails_helper'

RSpec.describe DeletedCandidate do
  describe '#readonly?' do
    it 'returns true if record exists' do
      deleted_candidate = create(:deleted_candidate)
      expect(deleted_candidate.readonly?).to be true
    end

    it 'returns false if new record' do
      expect(described_class.new.readonly?).to be false
    end
  end

  describe '#delete' do
    it 'raises exception' do
      deleted_candidate = create(:deleted_candidate)

      expect { deleted_candidate.delete }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedCandidate is marked as readonly',
      )
      expect(described_class.exists?(deleted_candidate.id)).to be true
    end
  end

  describe '.delete' do
    it 'raises exception' do
      deleted_candidate = create(:deleted_candidate)

      expect { described_class.delete(deleted_candidate.id) }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedCandidate is marked as readonly',
      )
      expect(described_class.exists?(deleted_candidate.id)).to be true
    end
  end

  describe '.delete_all' do
    it 'raises exception' do
      deleted_candidate = create(:deleted_candidate)

      expect { described_class.delete_all }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedCandidate is marked as readonly',
      )
      expect(described_class.exists?(deleted_candidate.id)).to be true
    end
  end

  describe '.update_all' do
    it 'raises exception' do
      deleted_candidate = create(:deleted_candidate)

      expect { described_class.update_all(candidate_id: 1) }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedCandidate is marked as readonly',
      )
      expect(deleted_candidate.candidate_id).not_to eq(1)
    end
  end
end
