require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'zip_dsl'
require 'file_utils/file_utils'

describe ZipDSL do
  include FileUtils

  let(:from_dir) { "." }

  subject { ZipDSL.new "build/test.zip", from_dir }

  after do
    delete_directory "build"
  end

  describe "#build" do
    it "creates new zip file with files at particular folder" do
      subject.build do
        file :name => "Gemfile"
        file :name => "Rakefile", :to_dir => "my_config"
        file :name => "spec/spec_helper.rb", :to_dir => "my_config"
      end

      expect(subject.entry_exist?("Gemfile")).to be_truthy
      expect(subject.entry_exist?("my_config/Rakefile")).to be_truthy
      expect(subject.entry_exist?("my_config/spec_helper.rb")).to be_truthy

      expect(subject.entries_size).to eq 3
    end

    it "creates new zip file with file created from string" do
      subject.build do
        content :name => "README", :source => "My README file content"
      end

      expect(subject.entry_exist?("README")).to be_truthy
      expect(subject.entries_size).to eq 1
    end

    it "creates new zip file with file created from file" do
      src = File.open("#{from_dir}/Rakefile")
      subject.build do
        content :name => "Rakefile",  :source => src
      end

      expect(subject.entry_exist?("Rakefile")).to be_truthy
      expect(subject.entries_size).to eq 1
    end

    it "should create new zip file with new empty folder" do
      subject.build do
        directory :to_dir => "my_config"
      end

      expect(subject.entry_exist?("my_config")).to be_truthy
      expect(subject.entries_size).to eq 1
    end

    it "creates new zip file with new folder" do
      subject.build do
        directory :from_dir => "spec", :to_dir => "my_config"
      end

      expect(subject.entry_exist?("my_config")).to be_truthy
      expect(subject.entries_size).to be > 1
    end

    it "updates existing zip file" do
      subject.build do
        file :name => "Gemfile"
      end

      expect(File.exist?(subject.name)).to be_truthy
      expect(subject.entry_exist?("Gemfile")).to be_truthy

      subject.build do
        file :name => "README.md"
        directory :from_dir => "lib"
      end

      expect(subject.entry_exist?("Gemfile")).to be_truthy
      expect(subject.entry_exist?("README.md")).to be_truthy
      expect(subject.entry_exist?("lib/zip_dsl/version.rb")).to be_truthy
    end

    it "excludes specified directories" do
      subject = ZipDSL.new "build/test.zip", from_dir, :excludes => [".git", ".idea", ".DS_Store"]

      subject.build do
        directory :from_dir => ".", :excludes => ["build"]
      end

      expect(subject.entry_exist?("build")).to be_falsey
      expect(subject.entry_exist?(".git")).to be_falsey
    end
  end

  describe "#list" do
    it "displays files in current directory" do
      subject.build do
        directory :from_dir => "spec"
      end

      expect(subject.list).to include "spec/spec_helper.rb"
    end

    it "displays files in specified subdirectory" do
      subject.build do
        directory :from_dir => "lib"
      end

      expect(subject.list("lib/zip_dsl").first).to match %r{lib/zip_dsl/version.rb}
    end
  end

  describe "#each_entry" do
    it "displays files in specified subdirectory" do
      subject.build do
        directory :from_dir => "lib"
      end

      contents = []

      subject.each_entry("lib/zip_dsl") do |content|
        contents << content
      end

      expect(contents.first.name).to eq "lib/zip_dsl/version.rb"
      expect(contents.first.get_input_stream.read).to match %r{class ZipDSL}
    end
  end
end
