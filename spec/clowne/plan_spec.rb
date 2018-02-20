describe Clowne::Plan do
  describe '#declarations' do
    let(:registry) do
      Clowne::Adapters::Registry.new.tap do |r|
        r.append :a
        r.append :b
        r.append :c
      end
    end

    subject { described_class.new(registry) }

    it 'works' do
      subject.add :b, 'item_1'
      subject.set :c, 'scalar_1'
      subject.add_to :a, :key_1, 'value_1'
      subject.add_to :a, :key_2, 'value_2'
      subject.add :b, 'item_2'

      expect(subject.declarations).to eq(
        [
          [:a, 'value_1'],
          [:a, 'value_2'],
          [:b, 'item_1'],
          [:b, 'item_2'],
          [:c, 'scalar_1']
        ]
      )

      subject.remove(:c)
      subject.remove_from(:a, :key_1)

      # return the same cached version
      expect(subject.declarations).to eq(
        [
          [:a, 'value_1'],
          [:a, 'value_2'],
          [:b, 'item_1'],
          [:b, 'item_2'],
          [:c, 'scalar_1']
        ]
      )

      expect(subject.declarations(true)).to eq(
        [
          [:a, 'value_2'],
          [:b, 'item_1'],
          [:b, 'item_2']
        ]
      )

      subject.add_to(:a, :key_1, 'new_item')

      expect(subject.declarations(true)).to eq(
        [
          [:a, 'value_2'],
          [:b, 'item_1'],
          [:b, 'item_2']
        ]
      )
    end
  end
end
