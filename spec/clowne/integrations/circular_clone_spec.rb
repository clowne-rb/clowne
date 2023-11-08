# frozen_string_literal: true

describe "Circular clone (https://github.com/clowne-rb/clowne/issues/69)", :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class TableCloner < Clowne::Cloner
        adapter :active_record

        include_association :rows
        include_association :columns
      end

      class RowCloner < Clowne::Cloner
        adapter :active_record

        finalize do |source, record, **params|
          record.title = "Clone of #{source.title}"
        end
      end

      class ColumnCloner < Clowne::Cloner
        adapter :active_record

        finalize do |source, record, **params|
          record.title = "Clone of #{source.title}"
        end
      end

      class CellCloner < Clowne::Cloner
        adapter :active_record

        finalize do |source, record, **params|
          mapper = params[:mapper]

          # remap cells to cloned rows and columns
          record.row_id = mapper.clone_of(AR::Row.new(id: source.row_id)).id
          record.column_id = mapper.clone_of(AR::Column.new(id: source.column_id)).id
        end
      end
    end
  end

  after(:all) do
    %w[TableCloner RowCloner ColumnCloner CellCloner].each do |cloner|
      AR.send(:remove_const, cloner)
    end
  end

  let!(:table) { create(:table) }
  let!(:rows) { create_list(:row, 3, table: table) }
  let!(:columns) { create_list(:column, 3, table: table) }
  let!(:cells) do
    3.times.flat_map do |i|
      create_list(:cell, 3, row: rows[i], column: columns[i])
    end
  end

  it "clone all stuff" do
    expect(AR::Table.count).to eq(1)
    expect(AR::Row.count).to eq(3)
    expect(AR::Column.count).to eq(3)
    expect(AR::Cell.count).to eq(3 * 3)

    operation = AR::TableCloner.call(table)
    cloned_table = operation.to_record

    # we need to save all records in one transaction to avoid partial clones
    ActiveRecord::Base.transaction do
      cloned_table.save!

      mapper = operation.mapper

      # replace with your cells selection logic
      cells.each do |cell|
        AR::CellCloner.call(cell, mapper: mapper).to_record.save!
      end
    end

    expect(cloned_table).to be_persisted

    expect(AR::Table.count).to eq(2)
    expect(AR::Row.count).to eq(6)
    expect(AR::Column.count).to eq(6)
    expect(AR::Cell.count).to eq(3 * 3 * 2)

    # test correct relations; we don't care about correct mapping
    # since it's tested in other specs
    AR::Cell.where.not(id: cells.map(&:id)).each do |cell|
      expect(cell.row.title).to include("Clone of")
      expect(cell.column.title).to include("Clone of")
    end
  end
end
