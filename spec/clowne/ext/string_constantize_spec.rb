# frozen_string_literal: true

require "clowne/ext/string_constantize"

describe Clowne::Ext::StringConstantize do
  using Clowne::Ext::StringConstantize

  it "works", :aggregate_failures do
    expect("::Clowne".constantize).to eq Clowne
    expect("Clowne".constantize).to eq Clowne
    expect("Clowne::Ext".constantize).to eq Clowne::Ext
    expect("CLownelqw".constantize).to be_nil
    expect("".constantize).to be_nil
  end
end
