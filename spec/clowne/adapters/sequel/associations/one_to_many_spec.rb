# frozen_string_literal: true

describe Clowne::Adapters::Sequel::Associations::OneToMany, :cleanup, adapter: :sequel do
  let(:adapter) { Clowne::Adapters::Sequel.new }
  let(:source) { create("sequel:user", :with_posts, posts_num: 2) }
  let(:record) { Sequel::User.new }
  let(:reflection) { Sequel::User.association_reflections[:posts] }
  let(:scope) { {} }
  let(:declaration_params) { {} }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(:posts, scope, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, adapter, params) }

  before(:all) do
    module Sequel
      class PostCloner < Clowne::Cloner
        include_associations :image, :tags

        finalize do |_source, record, **params|
          record.topic_id = params[:topic_id] if params[:topic_id]
        end

        nullify :topic_id, :owner_id

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + " (Cloned)"
          end
        end
      end
    end
  end

  after(:all) { Sequel.send(:remove_const, "PostCloner") }

  describe ".call" do
    subject { Clowne::Adapters::Sequel::Operation.wrap { resolver.call(record) }.to_record }

    it "infers default cloner from model name" do
      expect(subject.posts.size).to eq 2
      expect(subject.posts.first).to be_a(Sequel::Post)
      expect(subject.posts.first.image).to be_nil
      expect(subject.posts.first.to_hash).to eq(
        owner_id: nil,
        topic_id: nil,
        title: source.posts.first.title,
        contents: source.posts.first.contents
      )
      expect(subject.posts.second.to_hash).to eq(
        owner_id: nil,
        topic_id: nil,
        title: source.posts.second.title,
        contents: source.posts.second.contents
      )
    end

    context "when post has image" do
      let!(:images) do
        source.posts.map { |post| create("sequel:image", post: post) }
      end

      it "infers nested image cloner" do
        expect(subject.posts.first.image).to be_a(Sequel::Image)
        expect(subject.posts.first.image).to have_attributes(
          title: images.first.title
        )
      end
    end

    context "when post has tags" do
      let!(:tags) do
        source.posts.map do |post|
          create("sequel:tag").tap { |tag| tag.add_post(post) }
        end
      end

      it "infers nested image cloner" do
        post = subject.posts.first
        expect(post.tags.first).to be_a(Sequel::Tag)
        expect(post.tags.first).to have_attributes(
          value: tags.first.value
        )
      end
    end

    context "with params" do
      let(:declaration_params) { {params: true} }
      let(:params) { {topic_id: 123} }

      it "pass params to child cloner" do
        expect(subject.posts.size).to eq 2
        expect(subject.posts.first).to have_attributes(
          owner_id: nil,
          topic_id: 123
        )
        expect(subject.posts.second).to have_attributes(
          owner_id: nil,
          topic_id: 123
        )
      end
    end

    context "with scope" do
      context "block scope" do
        let(:scope) { ->(params) { where(title: params[:title]) if params[:title] } }
        let(:params) { {title: source.posts.first.title} }

        it "clones scoped children" do
          expect(subject.posts.size).to eq 1
          expect(subject.posts.first).to have_attributes(
            owner_id: nil,
            title: source.posts.first.title
          )
        end

        context "when block is no-op" do
          let(:params) { {} }

          it "clones all children" do
            expect(subject.posts.size).to eq 2
          end
        end
      end

      context "symbol scope" do
        let(:scope) { :alpha_first }

        let(:post1) { source.posts.first }
        let(:post2) { source.posts.second }

        before do
          post1.update title: "Zadyza"
          post2.update title: "Ta-dam"
        end

        it "clones scoped children" do
          expect(subject.posts.size).to eq 1
          expect(subject.posts.first).to have_attributes(
            owner_id: nil,
            title: "Ta-dam"
          )
        end
      end
    end

    context "with traits" do
      let(:declaration_params) { {traits: :mark_as_clone} }

      it "pass traits to child cloner" do
        expect(subject.posts.size).to eq 2
        expect(subject.posts.first).to have_attributes(
          owner_id: nil,
          topic_id: nil,
          title: "#{source.posts.first.title} (Cloned)"
        )
        expect(subject.posts.second).to have_attributes(
          owner_id: nil,
          topic_id: nil,
          title: "#{source.posts.second.title} (Cloned)"
        )
      end
    end

    context "with custom cloner" do
      let(:source) do
        create("sequel:user").tap do |user|
          create("sequel:post", title: "Some post", owner: user)
        end
      end

      let(:post_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |source, record, **_params|
            record.title = "Copy of #{source.title}"
          end
        end
      end

      let(:declaration_params) { {clone_with: post_cloner} }

      it "applies custom cloner" do
        expect(subject.posts.size).to eq 1
        expect(subject.posts.first).to have_attributes(
          owner_id: nil,
          topic_id: source.posts.first.topic_id,
          title: "Copy of Some post"
        )
      end
    end
  end
end
