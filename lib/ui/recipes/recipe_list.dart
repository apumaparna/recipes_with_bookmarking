import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  // All preferences need to use a unique key or they’ll be overwritten.
  // Here, you’re simply defining a constant for the preference key.
  static const String prefSearchKey = 'previousSearches';

  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  // This clears the way for you to save the user’s previous searches
  // and keep track of the current search.
  List<String> previousSearches = <String>[];

  // Here, you use the async keyword to indicate that this
  // method will run asynchronously. It also:
  // 1. Uses the await keyword to wait for an instance of SharedPreferences.
  // 2. Saves the list of previous searches using the prefSearchKey key.
  void savePreviousSearches() async {
    // 1
    final prefs = await SharedPreferences.getInstance();
    // 2
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  //This method is also asynchronous. Here, you:
  //1. Use the await keyword to wait for an instance of SharedPreferences.
  //2. Check if a preference for your saved list already exists.
  //3. Get the list of previous searches.
  //4. If the list is not null, set the previous searches, otherwise initialize an empty list.

  void getPreviousSearches() async {
    // 1
    // SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // 2
    if (prefs.containsKey(prefSearchKey)) {
      // 3
      final searches = prefs.getStringList(prefSearchKey);
      // 4
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }

  @override
  void initState() {
    super.initState();

    //loads any previous searches when the user restarts the app
    getPreviousSearches();

    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // replaces the icon with an IconButton that the user can tap to perform a search.
            //1. Add onPressed to handle the tap event.
            //2. Use the current search text to start a search.
            //3. Hide the keyboard by using the FocusScope class.
            IconButton(
              icon: const Icon(Icons.search),
              // 1
              onPressed: () {
                // 2
                startSearch(searchTextController.text);
                // 3
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),

            const SizedBox(
              width: 6.0,
            ),

            //3. Add a TextField to enter your search queries.
            //4. Set the keyboard action to TextInputAction.done. This closes the keyboard when the user presses the Done button.
            //5. Save the search when the user finishes entering text.
            //6. Create a PopupMenuButton to show previous searches.
            //7. When the user selects an item from previous searches, start a new search.
            //8. Build a list of custom drop-down menus (see widgets/custom_dropdown.dart) to display previous searches.
            //9. If the X icon is pressed, remove the search from the previous searches and close the pop-up menu.
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                      // 3
                      child: TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Search'),
                    autofocus: false,
                    // 4
                    textInputAction: TextInputAction.done,
                    // 5
                    onSubmitted: (value) {
                      if (!previousSearches.contains(value)) {
                        previousSearches.add(value);
                        savePreviousSearches();
                      }
                    },
                    controller: searchTextController,
                  )),
                  // 6
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    // 7
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      // 8
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
                              // 9
                              previousSearches.remove(value);
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // In this method, you:
  //1. Tell the system to redraw the widgets by calling setState().
  //2. Clear the current search list and reset the count, start and end positions.
  //3. Check to make sure the search text hasn’t already been added to the previous search list.
  //4. Add the search item to the previous search list.
  //5. Save the new list of previous searches.
  void startSearch(String value) {
    // 1
    setState(() {
      // 2
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();

      // 3
      if (!previousSearches.contains(value)) {
        // 4
        previousSearches.add(value);
        // 5
        savePreviousSearches();
      }
    });
  }

  Widget _buildRecipeLoader(BuildContext context) {
    if (searchTextController.text.length < 3) {
      return Container();
    }
    // Show a loading indicator while waiting for the movies
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
