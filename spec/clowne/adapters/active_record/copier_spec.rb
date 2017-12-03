describe Clowne::Adapters::ActiveRecord::Copier do
  let(:source) { create(:post) }

  subject { described_class.call(source) }

  it "get source's clone" do
    expect(subject).to be_a(::AR::Post)
    expect(subject).to be_new_record
    expect(subject.id).to be_nil
    expect(subject.created_at).to be_nil
    expect(subject.updated_at).to be_nil
  end
end
