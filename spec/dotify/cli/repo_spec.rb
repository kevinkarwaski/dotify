require 'spec_helper'
require 'dotify/cli/repo'

module Dotify
  module CLI
    describe Repo do

      let(:repo) { Repo.new("mattdbridges/dots") }
      subject { repo }

      it { should respond_to :repo }
      it { should respond_to :pull }

      describe "class methods" do
        subject { described_class }
        it { should respond_to :save }
      end

      describe "initialization" do
        subject { Repo.new("mattdbridges/dots", { :verbose => true }) }
        its(:repo) { should == 'mattdbridges/dots' }
        its(:options) { should == { :verbose => true } }
      end

      describe "#run_if_repo" do
        before { Repo.stub(:inform) }
        it "should yield the block if a .git directory exists in Dotify" do
          File.stub(:exists?).with(Config.path('.git')).and_return true
          expect { |b| Repo.run_if_repo(&b) }.to yield_control
        end
        it "should yield the block if a .git directory exists in Dotify" do
          File.stub(:exists?).with(Config.path('.git')).and_return false
          expect { |b| Repo.run_if_repo(&b) }.not_to yield_control
        end
        it "should call inform if a .git directory is missing" do
          File.stub(:exists?).with(Config.path('.git')).and_return false
          Repo.should_receive(:inform).once
          Repo.run_if_repo { }
        end
      end
    end
    describe Repo::Pull do
      let(:puller) { Repo::Pull.new('mattdbridges/dots', '/tmp/home/.dotify', { :verbose => false }) }

      describe "#github_repo_url" do
        it "should return a public repo url when env is public" do
          puller.stub(:use_ssh_repo?).and_return(false)
          expect(puller.url).to eq "git://github.com/mattdbridges/dots.git"
        end
        it "should return a SSH repo url when env is not public" do
          puller.stub(:use_ssh_repo?).and_return(true)
          expect(puller.url).to eq "git@github.com:mattdbridges/dots.git"
        end
      end

      describe "with :github => false option" do
        let(:puller) { Repo::Pull.new('git@example.com/some/path.git', '/tmp/home/.dotify', { :github => false, :verbose => false }) }
        it "should return the straight string without manipulation" do
          expect(puller.url).to eq 'git@example.com/some/path.git'
        end
      end

      describe "#use_ssh_repo?" do
        it "should return false if options[:ssh] is not true" do
          puller.stub(:options).and_return({ :ssh => false })
          expect(puller.use_ssh_repo?).to eq false
        end
        it "should return false if options[:ssh] is not even set" do
          puller.stub(:options).and_return({})
          expect(puller.use_ssh_repo?).to eq false
        end
        it "should return true if options[:ssh] is true" do
          puller.stub(:options).and_return({ :ssh => true })
          expect(puller.use_ssh_repo?).to eq true
        end
      end

      describe "#github_url" do
        it "should return false if options[:ssh] is not true" do
          puller.stub(:use_ssh_repo?).and_return true
          expect(puller.github_url).to eq "@github.com:"
        end
        it "should return false if options[:ssh] is not true" do
          puller.stub(:use_ssh_repo?).and_return false
          expect(puller.github_url).to eq "://github.com/"
        end
      end

      describe "#clone" do
        it "should delegate to Git clone and clone to the right place" do
          puller.stub(:path).and_return("/tmp/home/.dotify")
          puller.stub(:url).and_return("something")
          Git.should_receive(:clone).with("something", "/tmp/home/.dotify")
          puller.clone
        end
      end

    end
  end
end
