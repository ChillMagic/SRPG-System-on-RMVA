@echo off
cd %~dp0
::g++ -std=c++11 -s -O2 Combine.cpp -o temp.exe -I F:\Code\include
::cmd /k "temp.exe && exit"
::rem del /Q temp.exe
rem g++ -std=c++11 -s -O2 Combine.cc -o combine.exe -I F:\Code\include
combine.exe "1.0.0.0 Building" "02/28/2016" "{Kernel}.rb"
pause