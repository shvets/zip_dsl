# ZipDSL

Library for working with zip file in DSL-way

## Installation

Add this line to your application's Gemfile:

    gem 'zip_dsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zip_dsl

## Usage

You can create new archive:

```ruby
require 'zip_dsl'

zip_file = "test.zip"
from_dir = "."

zip_builder = ZipDSL.new zip_file, from_dir

zip_builder.build do
  # files from 'from_dir'
  file :name => "Gemfile"
  file :name => "Rakefile", :to_dir => "my_config"
  file :name => "spec/spec_helper.rb", :to_dir => "my_config"

  # create empty directory
  directory :to_dir => "my_config"

  # copy from one directory to another
  directory :from_dir => "spec", :to_dir => "my_spec"

  # create zip entry from arbitrary source: string or StringIO
  content :name => "README", :source => "My README file content"
end
```

or update existing archive:

```ruby
zip_builder.update do
  file :name => "README.md"
  directory :from_dir => "lib"
end
```

You can also display all entries from archive's folder:

```ruby
zip_builder.list("lib/zip_dsl")
```

or display entries

```ruby
zip_builder.each_entry("lib/zip_dsl") do |entry
  puts entry.name

  content = entry.get_input_stream.read

  puts content
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request