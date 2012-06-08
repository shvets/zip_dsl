require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'zip_dsl'

describe Zip::DSL do
  subject { Zip::DSL.new "test.zip" }

  it "should create new zip file with files at particular folder" do
    subject.build("test.zip") do
      file :name => "Gemfile"
      file :name => "Guardfile", :to_dir => "my_config"
      file :name => "config/boot.rb", :to_dir => "my_config"
    end

    subject.entry_exist?("Gemfile").should be_true
    subject.entry_exist?("my_config/Guardfile").should be_true
    subject.entry_exist?("my_config/boot.rb").should be_true

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
    subject.build do
      content :name => "Rakefile",  :source => File.open("Rakefile")
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
      directory :from_dir => "config", :to_dir => "my_config"
    end

    subject.entry_exist?("my_config").should be_true
    subject.entries_size.should > 1
  end

  it "should display files in specified directory" do
    subject.build do
      directory :from_dir => "config"
    end

    subject.list.first.should == "config/application.rb"
  end

  it "should display files in specified subdirectory" do
    subject.build do
      directory :from_dir => "config"
    end

    subject.list("config/environments").first.should =~ %r{config/environments/development.rb}
  end
end
