RSpec.describe Clowne::Planner do
  describe 'compile' do
    let(:object) { double(reflections: {"users" => nil, "posts" => nil}) }

    subject { described_class.compile(cloner, object) }

    context 'when simple cloner with one included association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_association :users
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::IncludeAssociation, {name: :users} ]
      ]) }
    end
  end
end
