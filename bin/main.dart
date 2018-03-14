import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:twitter/twitter.dart';
import 'twitterKeys.dart' as twitterKeys;

main() async {
  var envVars = twitterKeys.main();
  print(envVars[0]);
  print(envVars[1]);
  print(envVars[2]);
  print(envVars[3]);

  getLink();

}

Future getLink() async {
  int i;
  List scrapeLinks = [];
  http.Response response = await http.get("https://genius.com");

  Document document = parser.parse(response.body);
  await for (Element element in tagStream(document, 'chart_row')) {
    for (i = 0; i <= element.querySelectorAll('a').length;i++ ){
      var link = element.attributes.values.first;
      scrapeLinks.add(link);
    }
  }

  getLyrics(scrapeLinks);
}

Future getLyrics(List scrapeLinks) async {
  List lyrics = [];

  _deleteAllBreaks(List br) {
    for(var b in br) {
      b.remove();
    }
  }

  for(var link in scrapeLinks) {
    http.Response response = await http.get(link);
    Document document = parser.parse(response.body);

    await for (Element element in selectorStream(document, '.lyrics a')) {
        _deleteAllBreaks(element.getElementsByTagName('br'));
        var lyricItem = element.innerHtml;

        if(lyricItem.length < 140) {
          lyrics.add(lyricItem);
        }
    }
  }

  var tweet = (lyrics..shuffle()).first;
  PostTweet(tweet);
}

Stream selectorStream(Document document, String tag) async*{
  for(Element element in document.querySelectorAll(tag)){
    yield element;
  }
}

Stream tagStream(Document document, String tag) async*{
  for(Element element in document.getElementsByClassName(tag)){
    yield element;
  }
}


void PostTweet(String tweet) {
  print("Attempting to tweet: " + tweet);
  var envVars = twitterKeys.main();
  var keyMap = {
    "consumerKey": envVars[0],
    "consumerSecret": envVars[1],
    "accessToken": envVars[2],
    "accessSecret": envVars[3]
  };

  Twitter twitter = new Twitter.fromMap(keyMap);

  try {
    var a = twitter.request(
      "POST",
      "statuses/update.json",
      //Body of tweet is inserted below
      body: {"status" : tweet}
    );
      a.then((value){
        new File("test.json").writeAsString(value.body);
      });
    } catch(e) {
    } finally {
  }
  return;
}

Future<Document> getHtml(String url) =>
    new HttpClient()
        .getUrl(Uri.parse(url))
        .then((req) => req.close())
        .then((res) => res
        .asyncExpand((bytes) => new Stream.fromIterable(bytes))
        .toList())
        .then((bytes) => parser.parse(bytes, sourceUrl: url));
