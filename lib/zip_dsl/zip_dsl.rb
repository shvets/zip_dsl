require 'meta_methods'

class ZipDSL
  include MetaMethods

  attr_reader :name, :basedir

  def initialize name, basedir
    @name = File.expand_path(name)
    @basedir = File.expand_path(basedir)
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipWriter.new(name, @basedir) }
    destroy_block = lambda {|writer| writer.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def update(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipUpdater.new(name, @basedir) }
    destroy_block = lambda {|updater| updater.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entry_exist? entry_name
    create_block = lambda { ZipReader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entry_exist?(entry_name) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entries_size
    create_block = lambda { ZipReader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entries_size }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def list dir="."
    create_block = lambda { ZipReader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.list(dir) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

end

