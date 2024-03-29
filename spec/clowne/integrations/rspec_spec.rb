# frozen_string_literal: true

require "spec_helper"
require "clowne/rspec"

describe "RSpec matchers and helpers", adapter: :active_record do
  before(:all) do
    module RSpecTest
      class ImageCloner < Clowne::Cloner
        trait :with_preview_image do
          include_association :preview_image, params: :preview_image
        end

        trait :nullify_title do
          nullify :title
        end
      end

      class PostCloner < Clowne::Cloner
        include_association :image, clone_with: "RSpecTest::ImageCloner",
          traits: %i[with_preview_image nullify_title],
          params: true

        include_association :tags, ->(params) { where(value: params[:tags]) if params[:tags] }

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + " Super!"
          end
        end

        trait :without_tags do
          exclude_association :tags
        end

        trait :with_popular_tags do
          include_association :tags, :popular
        end

        trait :copy do
          init_as do |source, target:, **|
            target.contents = source.contents
            target
          end
        end
      end

      class PreviewImageCloner < Clowne::Cloner
        finalize do |_source, record, suffix:|
          record.some_stuff = record.some_stuff + suffix
        end
      end
    end
  end

  after(:all) do
    %w[ImageCloner PostCloner PreviewImageCloner].each do |cloner|
      RSpecTest.send(:remove_const, cloner)
    end
  end

  describe "#clone_associations", type: :cloner do
    subject { RSpecTest::PostCloner }

    it "asserts when all associations specified" do
      expect(subject).to clone_associations(:image, :tags)
    end

    it "refutes when not all specified" do
      expect do
        expect(subject).to clone_associations(:tags)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "raises ArgumentError when called not on cloner" do
      expect do
        expect("foo").to clone_associations(:tags)
      end.to raise_error(ArgumentError)
    end

    context "with traits" do
      it "asserts when all associations specified" do
        expect(subject).to clone_associations(:image).with_traits(:without_tags)
      end

      it "refutes when not all specified" do
        expect do
          expect(subject).to clone_associations(:tags, :image)
            .with_traits(:without_tags)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end

  describe "#clone_association", type: :cloner do
    subject { RSpecTest::PostCloner }

    it "asserts when association is included" do
      expect(subject).to clone_association(:image)
    end

    it "refutes when association is not included (with traits)" do
      expect do
        expect(subject).to clone_association(:tags).with_traits(:without_tags)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    context "clone_with" do
      it "asserts when cloner is correct" do
        expect(subject).to clone_association(
          :image,
          clone_with: RSpecTest::ImageCloner
        )
      end

      it "refutes when cloner is incorrect" do
        expect do
          expect(subject).to clone_association(
            :image,
            clone_with: RSpecTest::PreviewImageCloner
          )
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "asserts with implicit cloner" do
        expect(subject).to clone_association(:tags, clone_with: nil)
      end
    end

    context "traits" do
      it "asserts when all traits specified" do
        expect(subject).to clone_association(
          :image,
          traits: [:with_preview_image, :nullify_title]
        )
      end

      it "refutes when not all traits specified" do
        expect do
          expect(subject).to clone_association(
            :image,
            traits: :with_preview_image
          )
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    context "scope" do
      it "asserts when scope is correct" do
        expect(subject).to clone_association(
          :tags,
          scope: :popular
        ).with_traits(:with_popular_tags)
      end

      it "refutes when scope is incorrect" do
        expect do
          expect(subject).to clone_association(
            :tags,
            scope: :unpopular
          ).with_traits(:with_popular_tags)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "refutes when scope is dynamic" do
        expect do
          expect(subject).to clone_association(
            :tags,
            scope: ->(params) { where(value: params[:tags]) if params[:tags] }
          )
        end.to raise_error(ArgumentError)
      end
    end

    context "params" do
      subject { RSpecTest::ImageCloner }

      it "asserts when correct" do
        expect(subject).to clone_association(
          :preview_image,
          params: :preview_image
        ).with_traits(:with_preview_image)
      end

      it "refutes when incorrect" do
        expect do
          expect(subject).to clone_association(
            :preview_image,
            params: nil
          ).with_traits(:with_preview_image)
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end
end
