import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as gv;

class ViewContent extends StatefulWidget {
  const ViewContent(
      {Key? key, required this.contentTitle, required this.contentIndex})
      : super(key: key);
  final String contentTitle;
  final int contentIndex;

  @override
  _ViewContentState createState() => _ViewContentState();
}

class _ViewContentState extends State<ViewContent> {
  String currentChapterFile = "ch1.md"; // assign it from contentTitle
  int currentChapterNo = 0;

  @override
  void initState() {
    super.initState();
    currentChapterNo = widget.contentIndex;
    currentChapterFile = gv.chapters[currentChapterNo];
  }

  _saveLastPoint(int sp) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('LastSavedPoint', sp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(
                  gv.contents[currentChapterNo],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              color: Colors.blueGrey[200],
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                  future:
                      rootBundle.loadString("assets/ch/" + currentChapterFile),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Markdown(data: snapshot.data!);
                    }
                    return const Center(child: CircularProgressIndicator());
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => {
              if (currentChapterNo > 0)
                {
                  setState(() {
                    currentChapterNo -= 1;
                    currentChapterFile = gv.chapters[currentChapterNo];
                    _saveLastPoint(currentChapterNo);
                  }),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("No previous chapter..!"),
                  ))
                }
            },
            child: const Icon(Icons.navigate_before_rounded),
            tooltip: "Previous chapter",
            heroTag: "fab1",
          ),
          FloatingActionButton(
            onPressed: () => {
              if (currentChapterNo != gv.contents.length - 1)
                {
                  setState(() {
                    currentChapterNo++;
                    currentChapterFile = gv.chapters[currentChapterNo];
                    _saveLastPoint(currentChapterNo);
                  }),
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("That's Great..!, You’re All Caught Up"),
                  ))
                }
            },
            child: const Icon(Icons.navigate_next_rounded),
            tooltip: "Next chapter",
            heroTag: "fab2",
          ),
        ],
      ),
    );
  }
}
