require 'zip/zip'

class ZipUpdater

  def initialize file_name, basedir
    @zipfile = Zip::ZipFile.open(file_name)
    @basedir = basedir
  end

  def close
    @zipfile.close
  end

  def file params
    to_dir = params[:to_dir].nil? ? File.dirname(params[:name]) : strip_dot(params[:to_dir])

    add_or_replace_file full_name(params[:name]), "#{to_dir}/#{params[:name]}"
  end

  def content params
    to_dir = params[:to_dir].nil? ? File.dirname(params[:name]) : params[:to_dir]

    add_or_replace_file params[:name], to_dir, params[:source]
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

    #Dir["spec/stubs/**/*.*"].each do |name|
    #  if File.file? name
    #    add_or_replace(zipfile, "WEB-INF/spec/stubs/#{name['spec/stubs'.size+1..-1]}", name)
    #  end
    #end
  end

  private

  def add_or_replace_file from_name, to_name
    begin
      @zipfile.add to_name, from_name
    rescue Zip::ZipEntryExistsError
      @zipfile.replace to_name, from_name
    end
  end

  def add_directory from_dir, to_dir, filter="**/*"
    patterns = filter.kind_of?(String) ? [filter] : filter

    patterns.each do |pattern|
      files = pattern_to_files full_name(from_dir), pattern

      files.each do |from_name|
        suffix = File.dirname(from_name)[full_name(from_dir).size+1..-1]
        dir = suffix.nil? ? to_dir : "#{to_dir}/#{suffix}"

        if File.file?(from_name)
          to_name = "#{dir}/#{from_name[full_name(dir).size+1..-1]}"

          add_or_replace_file from_name, to_name
        end
      end
    end
  end

  def add_empty_directory(name)
    puts "adding empty dir: #{name}"

    #entry = Zip::ZipStreamableDirectory.new "", "#{name}/"
    #
    #@zos.put_next_entry entry
  end

  def pattern_to_files dir, pattern
    Dir.glob("#{dir}/#{pattern}")
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
    full_name?(name) ? name : "#@basedir/#{name}"
  end

end
