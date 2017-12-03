describe Clowne::Adapters::Sequel::Copier do
  let(:source) { create('sequel:post') }

  subject { described_class.call(source) }

  it "get source's clone" do
    expect(subject).to be_a(::Sequel::Post)
    expect(subject).to be_new
    expect(subject.id).to be_nil
    expect(subject.created_at).to be_nil
    expect(subject.updated_at).to be_nil
  end
end
