require 'rspec/expectations'

RSpec::Matchers.define :be_a_declarations do |expected_declarations|
  match do |actual| # TODO: write humanable error message
    expect(actual.count).to eq(expected_declarations.count)
    actual.each_with_index do |actual_declaration, index|
      expect(actual_declaration).to be_a_declaration(expected_declarations[index])
    end
  end
end

RSpec::Matchers.define :be_a_declaration do |declaration_class, values|
  match do |actual|
    expect(actual).to be_a(declaration_class)
    values.each do |field, value|
      actual_value = actual.public_send(field)
      if declaration_class == Clowne::Declarations::Trait && field == :block
        expect(actual_value).to be_a(Proc)
      elsif value.is_a?(Proc)
        expect(actual_value.call).to eq(value.call)
      else
        expect(actual_value).to eq(value)
      end
    end
  end
end
