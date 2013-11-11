require 'meta_methods/meta_methods'

class ZipDSL
  include MetaMethods

  attr_reader :from_root, :to_root, :name

  def initialize from_root, to_root, name
    @from_root = File.expand_path(from_root)
    @to_root = File.expand_path(to_root)
    @name = name

    FileUtils.mkdir_p(to_root) unless File.exists? to_root
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipWriter.new(from_root, to_root, name) }
    destroy_block = lambda {|writer| writer.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def update(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipUpdater.new(from_root, to_root, name) }
    destroy_block = lambda {|updater| updater.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entry_exist? entry_name
    create_block = lambda { ZipReader.new(to_root, name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entry_exist?(entry_name) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entries_size
    create_block = lambda { ZipReader.new(to_root, name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entries_size }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def list dir="."
    create_block = lambda { ZipReader.new(to_root, name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.list(dir) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def each_entry dir=".", &code
    create_block = lambda { ZipReader.new(to_root, name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.each_entry(dir, &code) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end
end

