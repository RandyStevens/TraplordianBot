import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:twitter/twitter.dart';
import 'twitterKeys.dart' as twitterKeys;

main() async {
///You can use the following commented code to check what your keys are.
//  var envVars = twitterKeys.main();
//  print(envVars[0]);
//  print(envVars[1]);
//  print(envVars[2]);
//  print(envVars[3]);

  ///To get started we run getLinks passing in null
  getLinks(null);

}

dynamic getLinks(_) async {
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
  ///Generate a list of links and pass it to getLyrics
  getLyrics(scrapeLinks);
  ///This just lets us know that we are waiting now, the function has finished
  print('Now waiting for 4 hours');
  ///Recursively create a new getLinks, it will wait 4 hours then run again.
  new Future.delayed(const Duration(hours: 4), (){}).then(getLinks);
}

Future getLyrics(List scrapeLinks) async {
  List lyrics = [];

  _deleteAllBreaks(List br) {
    for(var b in br) {
      b.remove();
    }
  }

  _deleteAllEms(List em) {
    for(var b in em) {
      b.remove();
    }
  }

  for(var link in scrapeLinks) {
    http.Response response = await http.get(link);
    Document document = parser.parse(response.body);

    await for (Element element in selectorStream(document, '.lyrics a')) {
        _deleteAllBreaks(element.getElementsByTagName('br'));
        _deleteAllEms(element.getElementsByTagName('em'));
        var lyricItem = element.innerHtml;

        if(lyricItem.length < 140) {
          lyrics.add(lyricItem);
        }
    }
  }
  ///Shuffle the array of viable tweets and take the first one
  var tweet = (lyrics..shuffle()).first;
  ///Post the tweet
  await PostTweet(tweet);
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
  var envVars = twitterKeys.keys();
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
