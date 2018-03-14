import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LinkData {

  Map links;

  LinkData(this.links);

  getLinks() {
    var decoder = new LinkDecoder();
    List LinkList = decoder.convert(links).toList();
    return LinkList;
  }
}

class LinkDecoder extends Converter<Map, Iterable<LinkData>> {
  const LinkDecoder();

  @override
  Iterable<LinkData> convert(Map<dynamic, dynamic> raw) {
    return raw.keys.map((key) => new LinkData(key));
  }
}

Future<List> getLinks() async {
  var path = '../writes/links.json';
  var response = await http.get(path);
  var parsed = JSON.decode(response.body);
  var decoder = new LinkDecoder();
  List linkList = decoder.convert(parsed).toList();
  return linkList;
}