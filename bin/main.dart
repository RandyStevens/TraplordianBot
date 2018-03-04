import 'package:twitter/twitter.dart';
import 'dart:io';

main() async{
  var envVars = Platform.environment;

  print(envVars['CONSUMER_KEY']);
  print(envVars['CONSUMER_SECRET']);
  print(envVars['ACCESS_TOKEN']);
  print(envVars['ACCESS_SECRET']);

  var keyMap = {
    "consumerKey": envVars['CONSUMER_KEY'],
    "consumerSecret": envVars['CONSUMER_SECRET'],
    "accessToken": envVars['ACCESS_TOKEN'],
    "accessSecret": envVars['ACCESS_SECRET']
  };
  Twitter twitter = new Twitter.fromMap(keyMap);

  try {
    var a = twitter.request(
        "POST",
        "statuses/update.json",
        //Body of tweet will go below
        body: {"status":"env var test"});

    a.then((value){
      new File("test.json").writeAsString(value.body);
    });
  } catch(e) {
  } finally {
  }
  return;
}