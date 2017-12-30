describe Clowne::Adapters::Registry do
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
