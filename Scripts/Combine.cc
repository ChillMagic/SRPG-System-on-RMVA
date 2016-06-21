// 2016-02-27
#include <file.h>
#include <charptr.h>
#include <date.h>
#include <string>
#include <vector>
#include <prints.h>
//#include <iostream>
using SYSTEM;
using namespace std;
USING Output;

inline bool foward_match(const string &sour, const string &find)
{
  return sour.substr(0,find.length()) == find;
}
inline bool match(const string &sour, const string &find)
{
  return sour.find(find) != string::npos;
}

File save(File::SAVE_TEXT);

void savefile(const string &filename)
{
  File load(filename.c_str(), File::LOAD_TEXT);
  string line;
  while (!load.end()) {
    line = load.getline();
    if (foward_match(line,"import") || foward_match(line,"require_relative")) {
      string fn = line.substr(8,line.length()-1-8) + ".rb";
      println(fn);
      savefile(fn);
    }
    else if (match(line,"require_relative") || match(line,"#!usr/bin/ruby")) {
      continue;
    }
    else
      save.putline(line);
  }
  if (line != "")
    save.putline("");
}

int main(int argc, char *argv[])
{
  string version, update, savename;
  if (argc < 4) {
    version = "1.0.0.0 Building";
    update  = date();
    savename = "{Kernel}.rb";
  }
  else {
    version = argv[1];
    update  = argv[2];
    savename = argv[3];
  }
  println("Version : " + version);
  println("Update Date: " + update);
  save.open(savename);
  
  save.putline("#==============================================================================\n"
               "# SMRC Kernel\n"
              "# Author : Chill");
  save.putline("# Version : " + version);
  save.putline("# Update Date: " + update);
  save.putline("#==============================================================================");
  savefile("main.rb");
}