require 'clowne/ext/string_constantize'
using Clowne::Ext::StringConstantize

describe Clowne::Ext::StringConstantize do
  it 'works', :aggregate_failures do
    expect('::Clowne'.constantize).to eq Clowne
    expect('Clowne'.constantize).to eq Clowne
    expect('Clowne::Ext'.constantize).to eq Clowne::Ext
    expect { 'CLownelqw'.constantize }.to raise_error(NameError)
    expect { ''.constantize }.to raise_error(NameError)
  end
end
