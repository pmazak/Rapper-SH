# Rapper-SH
A shell wrapper that offers help usage and available commands. Provides for a consistent interface for all your scripts. Works with any scripting language (bash, ruby, python, groovy, etc.). Even comes with tab auto-completion on available commands!

# Examples
```
[me@linux ~]$ rap help
Usage:
  rap <command> <arg1> <arg2> ...
  rap help <command>
  rap help all
  rap cat <command>
Available commands:
  exportData            (sh)      Exports some data as comma-delimited
  grepLogs              (sh)      Runs the log grepper job
```

```
[me@linux ~]$ rap help exportData
Usage:
  rap exportData <numRows>
Example:
  rap exportData 100
Description:
  Exports some data as comma-delimited
Type:
  (sh)
```

# Installation
1. Make your own scripts
1. Zip them up and deploy to a Linux server
1. Run these commands
```
mkdir -p ~/bin
cp rap-scripts.zip ~/
cp rap.sh ~/bin/rap
chmod 755 ~/bin/rap
```

# Convention
- Description is the first line in the script file as a commented line.
- Usage argument names are the second line in the script file as a commented line.
- Example arguments go on the third line of the script file as a commented line.
- You may choose to wrap (parentheses) around optional arguments.

# Advanced
- Put properties files and things you don't want listed as a command in a subfolder with prefix underscore **'_'**.
- Categorize your scripts into sub-folders and it will only show those commands if you run **rap help all**.
- Obviously, it doesn't need to be called "rap". You can invoke your packaged commands with a different prefix!
