describe Clowne::Plan do
  describe Clowne::Plan::Registry do
    subject { described_class.new }

    it 'works' do
      subject.append :a
      subject.prepend :b
      expect(subject.actions).to eq([:b, :a])

      subject.insert_before(:a, :c)
      expect(subject.actions).to eq([:b, :c, :a])

      subject.insert_before(:b, :d)
      expect(subject.actions).to eq([:d, :b, :c, :a])

      subject.insert_after(:d, :e)
      expect(subject.actions).to eq([:d, :e, :b, :c, :a])

      subject.insert_after(:a, :f)
      expect(subject.actions).to eq([:d, :e, :b, :c, :a, :f])
    end

    it 'raises if action is not unique' do
      subject.append :a

      expect { subject.prepend :a }.to raise_error(/already registered/)

      expect { subject.append :a }.to raise_error(/already registered/)

      subject.append :b

      expect { subject.insert_after :a, :b }.to raise_error(/already registered/)

      expect { subject.insert_before :a, :b }.to raise_error(/already registered/)
    end

    it 'raises if insert position is undefined' do
      expect { subject.insert_before :a, :b }.to raise_error(/not found/)

      expect { subject.insert_after :a, :b }.to raise_error(/not found/)
    end
  end

  describe '#declarations' do
    let(:registry) do
      described_class::Registry.new.tap do |r|
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

      expect(subject.declarations).to eq(
        [
          [:a, 'value_2'],
          [:b, 'item_1'],
          [:b, 'item_2']
        ]
      )
    end
  end
end
