require 'file_utils/directory_scanner'
require 'zip/zip'

class ZipWriter
  attr_reader :from_dir

  def initialize name, from_dir, includes=[], excludes=[]
    @from_dir = from_dir
    @global_includes = includes
    @global_excludes = excludes

    if File.exist?(name)
      @zipfile = Zip::ZipFile.open(name)
      @new_file = false
    else
      @compression_level = Zlib::BEST_COMPRESSION
      @zos = Zip::ZipOutputStream.new(name)
      @new_file = true
    end
  end

  def close
    @new_file ? @zos.close : @zipfile.close
  end

  def file params
    to_dir = params[:to_dir].nil? ? File.dirname(params[:name]) : strip_dot(params[:to_dir])

    if @new_file
      add_file full_name(params[:name]), to_dir
    else
      add_or_replace_file full_name(params[:name]), to_dir, params[:name]
    end
  end

  def content params
    to_dir = params[:to_dir].nil? ? File.dirname(params[:name]) : params[:to_dir]

    add params[:name], to_dir, params[:source]
  end

  def directory params
    if params[:from_dir].nil?
      add_empty_directory params[:to_dir]
    else
      if params[:to_dir].nil?
        to_dir = params[:from_dir]
      else
        to_dir = params[:to_dir]
      end

      includes = build_filter(params[:includes], @global_includes)
      excludes = build_filter(params[:excludes], @global_excludes)

      add_directory File.expand_path(params[:from_dir]), to_dir, includes, excludes
    end
  end

  private

  def build_filter from1, from2
    from1 = from1.nil? ? [] : from1
    from2 = from2.nil? ? [] : from2

    from1 + from2
  end

  def add_or_replace_file from_name, to_dir, name
    to_name = "#{to_dir}/#{name}"

    entry = @zipfile.find_entry(to_name)

    if entry
      @zipfile.replace to_name, from_name
    else
      @zipfile.add to_name, from_name
    end

    # begin
    #   @zipfile.add to_name, from_name
    # rescue Zip::ZipEntryExistsError
    #   @zipfile.replace to_name, from_name
    # end
  end

  def add_file name, to_dir = nil
    add name, to_dir, File.open(name)
  end

  def add_directory from, to_dir, includes, excludes
    scanner = DirectoryScanner.new
    files = scanner.scan full_name(from), false, :includes => includes, :excludes => excludes

    files.each do |file_name|
      suffix = File.dirname(file_name)[full_name(from).size+1..-1]
      dir = suffix.nil? ? to_dir : "#{to_dir}/#{suffix}"

      if File.file?(file_name)
        if @new_file
          add_file file_name, dir
        else
          to_name = "#{file_name[full_name(dir).size-11..-1]}"

          add_or_replace_file file_name, dir, to_name
        end
      end
    end
  end

  def add_empty_directory(name)
    if @new_file
      entry = Zip::ZipStreamableDirectory.new "", "#{name}/"

      @zos.put_next_entry entry
    else
      puts "adding empty dir: #{name}"

      #entry = Zip::ZipStreamableDirectory.new "", "#{name}/"
      #
      #@zos.put_next_entry entry
    end
  end

  def add name, to_dir, source
    create_new_entry("#{to_dir}/#{File.basename(name)}", source)
  end

  def create_new_entry(name, source)
    stream = source.kind_of?(String) ? StringIO.new(source) : source
    content = stream.read

    entry = Zip::ZipEntry.new("", name)

    @zos.put_next_entry entry, @compression_level

    @zos.write content
  end

  def strip_dot name
    if name[name.length-2..-1] == "/."
      name = name[0..name.length-3]
    end

    name
  end

  def full_name? name
    File.expand_path(name) == name
  end

  def full_name name
    full_name?(name) ? name : "#{from_dir}/#{name}"
  end

end
