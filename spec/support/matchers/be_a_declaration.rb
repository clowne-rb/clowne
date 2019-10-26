require "rspec/expectations"

RSpec::Matchers.define :match_declarations do |expected_declarations|
  match do |actual|
    expect(actual.count).to eq(expected_declarations.count)
    actual.each.with_index do |actual_declaration, index|
      expect(actual_declaration).to be_a_declaration(expected_declarations[index])
    end
  end
end

RSpec::Matchers.define :be_a_declaration do |type, declaration_class, attributes = {}|
  match do |(actual_type, declaration)|
    expect(actual_type).to eq type
    expect(declaration).to be_a(declaration_class)

    attributes.each do |field, value|
      actual_value = declaration.public_send(field)
      if value.is_a?(Proc)
        expect(actual_value.call).to eq(value.call)
      else
        expect(actual_value).to eq(value)
      end
    end
  end
end
