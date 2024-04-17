import 'dart:convert';
import 'dart:io';

void main() async {
  var res = await Process.run(
    'flutter',
    ['clean'],
    runInShell: true,
  );
  res = await Process.run(
    'flutter',
    ['build', 'windows'],
    runInShell: true,
    stderrEncoding: utf8,
    stdoutEncoding: utf8,
  );
  if (res.exitCode == 0) {
    print(res.stdout);
  } else {
    print(res.stderr);
  }
}
