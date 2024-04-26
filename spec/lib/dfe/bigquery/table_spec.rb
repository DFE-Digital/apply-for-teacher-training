require 'rails_helper'

RSpec.describe DfE::Bigquery::Table do
  subject(:table) { described_class.new(name: 'datapoint.magic_tricks') }

  describe '#to_sql' do
    context 'when using select string' do
      it 'returns select with exact string' do
        expect(
          table.select('one, two').to_sql,
        ).to eq(
          <<~SQL,
            SELECT one, two
            FROM datapoint.magic_tricks
          SQL
        )
      end
    end

    context 'when using select array' do
      it 'returns select with specified columns' do
        expect(
          table.select(%w[one two]).to_sql,
        ).to eq(
          <<~SQL,
            SELECT one, two
            FROM datapoint.magic_tricks
          SQL
        )
      end
    end

    context 'when using no select' do
      it 'returns select with star' do
        expect(
          table.to_sql,
        ).to eq(
          <<~SQL,
            SELECT *
            FROM datapoint.magic_tricks
          SQL
        )
      end
    end

    context 'when using where' do
      it 'returns where conditions using "AND"' do
        expect(
          table.where(
            magic_name: 'Battle of the Barrels',
            year: 1970,
          )
         .where(
           'magic_name != "Pulling bunny out of hat"',
         ).to_sql,
        ).to eq(
          <<~SQL,
            SELECT *
            FROM datapoint.magic_tricks
            WHERE magic_name = "Battle of the Barrels"
            AND year = 1970
            AND magic_name != "Pulling bunny out of hat"
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
        expect(table.order(magic_name: :asc).to_sql.squish).to eq(
          <<~SQL.squish,
            SELECT *
            FROM datapoint.magic_tricks
            #{default_order_clause}, magic_name ASC
          SQL
        )
      end
    end
  end

  def default_order_clause
    table.send(:default_order_clause, 'magic_name')
  end
end
