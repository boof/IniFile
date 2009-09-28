IniFile
=======

IniFile is a class for reading and writing .ini files with various options on
how to read/write them.

Features:
---------

  * different name/value delimiters (default is '=')
  * support for number sign comments (default is ';')
  * handlers for duplicate names (overwrite, concat and to\_array)
  * different section delimiters (default is '.') for hierarchy
  * customizable intendation string (default: '  ')

Behaviour:
----------

  * blank lines are ignored
  * whitespaces are ignored
  * comments are ignored
  * single and double quotes around values are deleted
  * duplicate names by default raises an IndexError

If you want to preserve the format of your .ini file try
[Anthony Williams's iniparse](http://github.com/antw/iniparse/).

### Reading

    config = IniFile.open(path) # or
    app = IniFile.open(path) { |config| App.new config }

### Writing

    File.open(path, 'w') { |file| IniFile.dump config, file }

_See rdoc for options on open and dump._

TODO
----

See IniFile::TODO.
