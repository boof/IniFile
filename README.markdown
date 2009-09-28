IniFile
=======

IniFile is a class for reading and writing .ini files with various options on
how to read/write them.

Reading
-------

    config = IniFile.open(path) # or
    app = IniFile.open(path) { |config| App.new config }

Writing
-------

    File.open(path, 'w') { |file| IniFile.dump config, file }

See rdoc for options.
