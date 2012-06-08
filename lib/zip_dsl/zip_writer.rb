require 'zip/zip'

class Zip::Writer

  def initialize file_name
    @zos = Zip::ZipOutputStream.new(file_name)

    @compression_level = Zlib::BEST_COMPRESSION
  end

  def close
    @zos.close
  end

  def file params
    to_dir = params[:to_dir].nil? ? File.dirname(params[:name]) : strip_dot(params[:to_dir])

    add_file params[:name], to_dir
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

      filter = params[:filter].nil? ? "**/*" : params[:filter]

      add_directory params[:from_dir], to_dir, filter
    end
  end

  private

  def add_file name, to_dir = nil
    add name, to_dir, File.open(name)
  end

  def add_directory from_dir, to_dir, filter="**/*"
    patterns = filter.kind_of?(String) ? [filter] : filter

    patterns.each do |pattern|
      files = pattern_to_files from_dir, pattern

      files.each do |file_name|
        suffix = File.dirname(file_name)[from_dir.size+1..-1]
        dir = suffix.nil? ? to_dir : "#{to_dir}/#{suffix}"

        if File.file?(file_name)
          add_file file_name, dir
        end
      end
    end
  end

  def pattern_to_files dir, pattern
    Dir.glob("#{dir}/#{pattern}")
  end

  def add_empty_directory(name)
    entry = Zip::ZipStreamableDirectory.new "", "#{name}/"

    @zos.put_next_entry entry
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

end
