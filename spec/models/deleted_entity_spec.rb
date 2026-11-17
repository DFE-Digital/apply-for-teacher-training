require 'rails_helper'

RSpec.describe DeletedEntity do
  describe '#readonly?' do
    it 'returns true if record exists' do
      deleted_entity = create(:deleted_entity)
      expect(deleted_entity.readonly?).to be true
    end

    it 'returns false if new record' do
      expect(described_class.new.readonly?).to be false
    end
  end

  describe '#delete' do
    it 'raises exception' do
      deleted_entity = create(:deleted_entity)

      expect { deleted_entity.delete }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedEntity is marked as readonly',
      )
      expect(described_class.exists?(deleted_entity.id)).to be true
    end
  end

  describe '.delete' do
    it 'raises exception' do
      deleted_entity = create(:deleted_entity)

      expect { described_class.delete(deleted_entity.id) }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedEntity is marked as readonly',
      )
      expect(described_class.exists?(deleted_entity.id)).to be true
    end
  end

  describe '.delete_all' do
    it 'raises exception' do
      deleted_entity = create(:deleted_entity)

      expect { described_class.delete_all }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedEntity is marked as readonly',
      )
      expect(described_class.exists?(deleted_entity.id)).to be true
    end
  end

  describe '.update_all' do
    it 'raises exception' do
      deleted_entity = create(:deleted_entity)

      expect { described_class.update_all(entity_id: 1) }.to raise_exception.with_message( # rubocop:disable RSpec/UnspecifiedException
        'DeletedEntity is marked as readonly',
      )
      expect(deleted_entity.entity_id).not_to eq(1)
    end
  end
end
