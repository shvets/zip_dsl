require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'zip_dsl'
require 'file_utils/file_utils'

describe ZipDSL do
  include FileUtils

  let(:from_basedir) { "." }
  let(:to_basedir) { "build" }

  subject { ZipDSL.new from_basedir, to_basedir, "test.zip" }

  describe "#build" do
    after do
      delete_directory "build"
    end

    it "should create new zip file with files at particular folder" do
      subject.build do
        file :name => "Gemfile"
        file :name => "Rakefile", :to_dir => "my_config"
        file :name => "spec/spec_helper.rb", :to_dir => "my_config"
      end

      subject.entry_exist?("Gemfile").should be_true
      subject.entry_exist?("my_config/Rakefile").should be_true
      subject.entry_exist?("my_config/spec_helper.rb").should be_true

      subject.entries_size.should == 3
    end

    it "should create new zip file with file created from string" do
      subject.build do
        content :name => "README", :source => "My README file content"
      end

      subject.entry_exist?("README").should be_true
      subject.entries_size.should == 1
    end

    it "should create new zip file with file created from file" do
      src = File.open("#{from_basedir}/Rakefile")
      subject.build do
        content :name => "Rakefile",  :source => src
      end

      subject.entry_exist?("Rakefile").should be_true
      subject.entries_size.should == 1
    end

    it "should create new zip file with new empty folder" do
      subject.build do
        directory :to_dir => "my_config"
      end

      subject.entry_exist?("my_config").should be_true
      subject.entries_size.should == 1
    end

    it "should create new zip file with new folder" do
      subject.build do
        directory :from_dir => "spec", :to_dir => "my_config"
      end

      subject.entry_exist?("my_config").should be_true
      subject.entries_size.should > 1
    end
  end

  describe "#update" do
    it "should update existing zip file" do
      subject.build do
        file :name => "Gemfile"
      end

      File.exist?("#{subject.to_root}/#{subject.name}").should be_true
      subject.entry_exist?("Gemfile").should be_true

      subject.update do
        file :name => "README.md"
        directory :from_dir => "lib"
      end

      subject.entry_exist?("Gemfile").should be_true
      subject.entry_exist?("README.md").should be_true
      subject.entry_exist?("lib/zip_dsl/version.rb").should be_true
    end
  end

  describe "#list" do
    it "should display files in current directory" do
      subject.build do
        directory :from_dir => "spec"
      end

      subject.list.should include "spec/spec_helper.rb"
    end

    it "should display files in specified subdirectory" do
      subject.build do
        directory :from_dir => "lib"
      end

      subject.list("lib/zip_dsl").first.should =~ %r{lib/zip_dsl/version.rb}
    end
  end

  describe "#each_entry" do
    it "should display files in specified subdirectory" do
      subject.build do
        directory :from_dir => "lib"
      end

      contents = []

      subject.each_entry("lib/zip_dsl") do |content|
        contents << content
      end

      contents.first.name.should == "lib/zip_dsl/version.rb"
      contents.first.get_input_stream.read.should =~ %r{class ZipDSL}
    end
  end
end
