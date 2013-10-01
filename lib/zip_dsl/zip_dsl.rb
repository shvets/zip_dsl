class ZipDSL
  attr_reader :name, :basedir

  def initialize basedir, name
    @name = File.expand_path(name)
    @basedir = File.expand_path(basedir)
  end

  def build(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipWriter.new(name, @basedir) }
    destroy_block = lambda {|writer| writer.close }

    evaluate(create_block, destroy_block, execute_block)
  end

  def update(name=nil, &execute_block)
    name = name.nil? ? @name : name

    create_block = lambda { ZipUpdater.new(name, @basedir) }
    destroy_block = lambda {|updater| updater.close }

    evaluate(create_block, destroy_block, execute_block)
  end

  def entry_exist? entry_name
    create_block = lambda { ZipReader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entry_exist?(entry_name) }

    evaluate(create_block, destroy_block, execute_block)
  end

  def entries_size
    create_block = lambda { ZipReader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.entries_size }

    evaluate(create_block, destroy_block, execute_block)
  end

  def list dir="."
    create_block = lambda { ZipReader.new(@name) }
    destroy_block = lambda {|reader| reader.close }
    execute_block = lambda { |reader| reader.list(dir) }

    evaluate(create_block, destroy_block, execute_block)
  end

  private

  def evaluate(create_block, destroy_block, execute_block)
    begin
      created_object = create_block.kind_of?(Proc) ? create_block.call : create_block

      created_object.instance_eval(&execute_block)
    ensure
      destroy_block.call(created_object) if destroy_block && created_object
    end
  end
end

