import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'token.dart';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GitHub with GraphQL in Flutter',
        home: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String personal_access_token = myToken().token;

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
        uri: 'https://api.github.com/graphql',
      headers: {
          "authorization": "Bearer $personal_access_token"
      }
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject)
      )
    );
    return GraphQLProvider(
      client: client,
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    String getRepositories = r"""
      query Flutter_GraphQL_GitHub {
        user(login: "frankdavid-addae") {
          avatarUrl(size: 200)
          location
          name
          url
          email
          login
          repositories {
            totalCount
          }
          followers {
            totalCount
          }
          following {
            totalCount
          }
        }
        viewer {
          starredRepositories(last: 12) {
            edges {
              node {
                id
                name
                nameWithOwner
              }
            }
          }
        }
      }
   """;
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub with GraphQL in Flutter'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Query(
        options: QueryOptions(
          document: getRepositories
        ),
        builder: (QueryResult result, {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.errors != null) {
            return Center(
              child: Text(
                result.errors.toString(),
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (result.loading) {
            return Center(child: CircularProgressIndicator());
          }

          final userDetails = result.data['user'];
          List starredRepositories = result.data['viewer']['starredRepositories']['edges'];

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        SizedBox(height: 2,),
                        ClipOval(
                          child: Image.network(
                            userDetails["avatarUrl"],
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          userDetails['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          userDetails['login'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              userDetails['location'],
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.link,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              userDetails['url'],
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.email,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 5,),
                            Text(
                              userDetails['email'],
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Repositories",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    userDetails["repositories"]["totalCount"].toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    userDetails["followers"]['totalCount']
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  )
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    userDetails["following"]['totalCount']
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Following",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8,),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 2, left: 10),
                child: Text(
                  "Starred Repositories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 330),
                child: ListView.builder(
                  itemCount: starredRepositories.length,
                  itemBuilder: (context, index) {
                    final repository = starredRepositories[index];
                    return Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 10),
                      child: Card(
                        elevation: 0,
                        child: Row(
                          children: [
                            Icon(Icons.collections_bookmark),
                            SizedBox(width: 5,),
                            Text(
                              repository['node']['nameWithOwner'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

