# frozen_string_literal: true

describe Clowne::Adapters::Sequel do
  let(:record) { create("sequel:post") }

  subject { described_class.dup_record(record) }

  it "get source's clone" do
    expect(subject).to be_a(::Sequel::Post)
    expect(subject).to be_new
    expect(subject.id).to be_nil
    expect(subject.created_at).to be_nil
    expect(subject.updated_at).to be_nil
  end
end
