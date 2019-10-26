describe Clowne::Utils::CloneMapper do
  subject(:mapper) { described_class.new }

  let(:origin) { create(:post) }
  let(:origin2) { create(:post) }

  let(:clone) { AR::Post.new }
  let(:clone2) { AR::Post.new }

  specify "mapper flow" do
    mapper.add(origin, clone)
    mapper.add(origin2, clone2)

    expect(mapper.clone_of(origin)).to eq(clone)
    expect(mapper.origin_of(clone)).to eq(origin)

    expect(mapper.clone_of(origin2)).to eq(clone2)
    expect(mapper.origin_of(clone2)).to eq(origin2)

    clone.save
    clone2.save

    expect(mapper.clone_of(origin)).to eq(clone)
    expect(mapper.origin_of(clone)).to eq(origin)

    expect(mapper.clone_of(origin2)).to eq(clone2)
    expect(mapper.origin_of(clone2)).to eq(origin2)
  end
end
