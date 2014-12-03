set RUBYOPT=-EUTF-8
cd /d %~dp0
cd ..
:: Change parent directory
grunt watch_files
:: watch start
cmd /k
