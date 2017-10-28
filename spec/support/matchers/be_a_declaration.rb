require 'rspec/expectations'

RSpec::Matchers.define :be_a_declaration do |declaration_class, values|
  match do |actual|
    expect(actual).to be_a(declaration_class)
    values.each do |field, value|
      actual_value = actual.public_send(field)
      if value.is_a?(Proc)
        expect(actual_value.call).to eq(value.call)
      else
        expect(actual_value).to eq(value)
      end
    end
  end
end
