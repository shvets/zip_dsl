require 'meta_methods'

class Zip::DSL
  include MetaMethods

  def initialize name, basedir
    @name = name
    @basedir = File.expand_path(basedir)
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { Zip::Writer.new(name, @basedir) }
    destroy_block = lambda {|writer| writer.close }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entry_exist? entry_name
    create_block = lambda { Zip::Reader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entry_exist?(entry_name) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def entries_size
    create_block = lambda { Zip::Reader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entries_size }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

  def list dir="."
    create_block = lambda { Zip::Reader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.list(dir) }

    evaluate_dsl(create_block, destroy_block, execute_block)
  end

end

