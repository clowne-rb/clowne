describe Clowne::Adapters::ActiveRecord::Associations::BelongsTo,
  :cleanup, adapter: :active_record do
  let(:adapter) { Clowne::Adapters::ActiveRecord.new }
  let(:topic) { create(:topic) }
  let(:source) { create(:post, topic: topic) }
  let(:reflection) { AR::Post.reflections["topic"] }
  let(:record) { AR::Post.new }
  let(:scope) { {} }
  let(:declaration_params) { {} }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(:topic, scope, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, adapter, params) }

  describe ".call" do
    subject { Clowne::Utils::Operation.wrap { resolver.call(record) }.to_record }

    it "clones the topic without cloner" do
      expect(subject.topic).to be_new_record
      expect(subject.topic).to have_attributes(
        title: topic.title,
        description: topic.description
      )
    end

    context "with custom cloner" do
      let(:topic_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |_source, record, params|
            record.title += params.fetch(:suffix, "-2")
            record.description += " (Cloned)"
          end

          trait :mark_as_clone do
            finalize do |_source, record|
              record.title += " (Cloned)"
            end
          end
        end
      end

      let(:declaration_params) { {clone_with: topic_cloner} }

      it "applies custom cloner" do
        expect(subject.topic).to be_new_record
        expect(subject.topic).to have_attributes(
          title: "#{topic.title}-2",
          description: "#{topic.description} (Cloned)"
        )
      end

      context "with params" do
        let(:declaration_params) { {clone_with: topic_cloner, params: true} }
        let(:params) { {suffix: "-new"} }

        it "pass params to child cloner" do
          expect(subject.topic).to be_new_record
          expect(subject.topic).to have_attributes(
            title: "#{topic.title}-new",
            description: "#{topic.description} (Cloned)"
          )
        end
      end

      context "with traits" do
        let(:declaration_params) { {clone_with: topic_cloner, traits: :mark_as_clone} }

        it "pass traits to child cloner" do
          expect(subject.topic).to be_new_record
          expect(subject.topic).to have_attributes(
            title: "#{topic.title}-2 (Cloned)",
            description: "#{topic.description} (Cloned)"
          )
        end
      end
    end
  end
end
