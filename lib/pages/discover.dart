import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memecentral/variables.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> searchResult;
  searchUser(String searchQuery) {
    print("searchQuery:" + searchQuery);
    var users = userCollection.where('username', isGreaterThanOrEqualTo: searchQuery).get();
    if (searchQuery != null && searchQuery != "") {
      setState(() {
        searchResult = users;
      });
    } else {
      setState(() {
        searchResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            prefixIcon: Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            hintStyle: fontStyle(18, Colors.white),
          ),
          onChanged: (text) => searchUser(text),
        ),
      ),
      body: searchResult == null
          ? Center(
              child: Text(
                "Search for users...",
                style: fontStyle(25),
              ),
            )
          : FutureBuilder(
              future: searchResult,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot user = snapshot.data.docs[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.search, color: Colors.white, size: 30),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(user.data()['profilePicture']),
                          ),
                          title: Text(
                            user.data()['username'],
                            style: fontStyle(22, Colors.white),
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
