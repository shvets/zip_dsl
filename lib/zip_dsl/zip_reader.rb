require 'zip/zip'

class ZipReader
  include Enumerable

  attr_reader :zis

  def initialize name
    @zis = Zip::ZipInputStream.new("#{name}")
  end

  def each(&block)
    zis.rewind

    while (entry = zis.get_next_entry)
      next if entry.name =~ %r{\.\.}
      block.call(entry)
    end
  end

  def close
    zis.close
  end

  def entry_exist? entry_name
    found = false

    self.each do |entry|
      if (entry.name == "./#{entry_name}") ||
           (entry.name == entry_name) ||
             !!(entry.name =~   /^#{entry_name}/)
        found = true
        break
      end
    end

    found
  end

  def entries_size
    cnt = 0

    self.each { |_| cnt +=1 }

    cnt
  end

  def list dir="."
    entries = []

    self.each do |entry|
      if entry.name =~ /#{dir}/
        name = (entry.name[0..1] == './') ? entry.name[2..-1] : entry.name

        entries << name
      end
    end

    entries
  end

  def each_entry dir=".", &code
    self.each do |entry|
      if entry.name =~ /#{dir}/
        code.call(entry)
      end
    end
  end

  private

  def dir_entry? entry
    (%r{\/$} =~ entry.name)
  end

end
