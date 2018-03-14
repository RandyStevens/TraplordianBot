import 'dart:io';

writeFile(String file, String data, FileMode mode) {
  try {
    File f = new File(file);
    RandomAccessFile rf = f.openSync(mode: mode);
    rf.writeStringSync(data);
    rf.flushSync();
    rf.closeSync(); // may call flush
    return true;
  }
  catch(e) {
    print(e.toString());
    return false;
  }
}

void list(String path) {
  try {
    Directory root = new Directory(path);
    if(root.existsSync()) {
      for(FileSystemEntity f in root.listSync()) {
        print(f.path);
      }
    }
  }
  catch(e) {
    print(e.toString());
  }
}