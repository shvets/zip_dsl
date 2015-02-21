require 'meta_methods/dsl_builder'

class ZipDSL
  attr_reader :name, :from_dir

  def initialize name, from_dir=".", params={}
    @name = name
    @from_dir = File.expand_path(from_dir)
    @includes = params[:includes]
    @excludes = params[:excludes]

    to_root = File.expand_path(File.dirname(name))
    FileUtils.mkdir_p(to_root) unless File.exists? to_root
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipWriter.new(name, from_dir, @includes, @excludes) }
    destroy_block = lambda {|writer| writer.close }

    MetaMethods::DslBuilder.instance.evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entry_exist? entry_name
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entry_exist?(entry_name) }

    MetaMethods::DslBuilder.instance.evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entries_size
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entries_size }

    MetaMethods::DslBuilder.instance.evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def list dir="."
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.list(dir) }

    MetaMethods::DslBuilder.instance.evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def each_entry dir=".", &code
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.each_entry(dir, &code) }

    MetaMethods::DslBuilder.instance.evaluate_dsl(create_block, destroy_block, execute_block)
  end
end

