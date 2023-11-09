require 'rails_helper'

RSpec.describe DfE::Bigquery::Table do
  subject(:table) { described_class.new(name: 'datapoint.magic_tricks') }

  describe '#to_sql' do
    context 'when using where' do
      it 'returns where conditions using "AND"' do
        expect(
          table.where(
            magic_name: 'Battle of the Barrels',
            year: 1970,
          ).to_sql,
        ).to eq(
          <<~SQL,
            SELECT *
            FROM datapoint.magic_tricks
            WHERE magic_name = "Battle of the Barrels"
            AND year = 1970
          SQL
        )
      end
    end

    context 'when not using where' do
      it 'returns default query' do
        expect(table.to_sql).to eq(
          <<~SQL,
            SELECT *
            FROM datapoint.magic_tricks
          SQL
        )
      end
    end

    context 'when order' do
      it 'returns order' do
        expect(table.order(magic_name: :asc).to_sql).to eq(
          <<~SQL,
            SELECT *
            FROM datapoint.magic_tricks
            ORDER BY magic_name ASC
          SQL
        )
      end
    end
  end
end
