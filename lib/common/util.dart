import 'dart:convert';

class Util {
  static const String THUNDER_PREFIX = 'thunder://';
  static const String HASH_PATTERN = "\\b[0-9a-fA-F]{5,40}\\b";
  static const supported = <String>['magnet', 'thunder', 'http', 'https', 'ftp', 'ed2k'];
  // 解析迅雷url
  static String parseThunder(String source) {
    if(source.startsWith(THUNDER_PREFIX)) {
      source =source.substring(THUNDER_PREFIX.length);
    }

    var result =latin1.decode(base64Decode(source));
    if(result.length > 4) {
      return result.substring(2, result.length - 2);
    } else {
      return '';
    }
  }

  static String normalizeURL(String url) {
    if(url.startsWith(THUNDER_PREFIX)) {
      return parseThunder(url);
    }

    // check support protocal
    var sub = url.length > 10 ? url.substring(0, 10) : url;
    sub=sub.toLowerCase();
    for(var item in supported) {
      if(sub.startsWith(item))
        return url;
    }

    if(url.startsWith('www')) {
      return 'http://' + url;
    }

    // check magnet:?xt=urn:btih:
    final regex =RegExp(HASH_PATTERN);
    final matches = regex.allMatches(url);
    for(var match in matches) {
      if(match.start == 0 && match.end  == url.length) {
        return 'magnet:?xt=urn:btih:' + url;
      }
    }

    return null;
  }

  static String toByteCountText(int bytes) {
    const tokens = <String>['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    int index = 0;
    double value = bytes.toDouble();
    while (value > 1024) {
      value /= 1024;
      index++;
    }

    return '${value.toStringAsPrecision(2)}${tokens[index]}';
  }
}