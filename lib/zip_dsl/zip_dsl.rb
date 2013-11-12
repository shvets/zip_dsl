require 'meta_methods/meta_methods'

class ZipDSL
  include MetaMethods

  attr_reader :name, :from_dir

  def initialize name, from_dir = nil
    @name = name
    @from_dir = from_dir.nil? ? from_dir : File.expand_path(from_dir)

    to_root = File.expand_path(File.dirname(name))
    FileUtils.mkdir_p(to_root) unless File.exists? to_root
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipWriter.new(name, from_dir) }
    destroy_block = lambda {|writer| writer.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def update(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipUpdater.new(name, from_dir) }
    destroy_block = lambda {|updater| updater.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entry_exist? entry_name
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entry_exist?(entry_name) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entries_size
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entries_size }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def list dir="."
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.list(dir) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def each_entry dir=".", &code
    create_block = lambda { ZipReader.new(name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.each_entry(dir, &code) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end
end

