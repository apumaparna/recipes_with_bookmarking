import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';
import '../../network/recipe_model.dart';
import 'package:flutter/services.dart';
import '../recipe_card.dart';
import 'recipe_details.dart';
import '../../network/recipe_service.dart';
import 'package:chopper/chopper.dart';
import '../../network/model_response.dart';
import 'dart:collection';

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

  List<APIHits> currentSearchList = [];

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
  // Add _currentRecipes1
  // APIRecipeQuery? _currentRecipes1 = null;

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
    // loadRecipes();
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

  // COMMENTED OUT WITH THE CHOPPER UPDATE
  // // 1: The method is asynchronous and returns a Future.
  // // It takes a query and the start and the end positions of the recipe data,
  // // which from and to represent, respectively.
  // Future<APIRecipeQuery> getRecipeData(String query, int from, int to) async {
  //   // 2: You define recipeJson, which stores the results from
  //   // RecipeService().getRecipes() after it finishes.
  //   // It uses the from and to fields from step 1.
  //   final recipeJson = await RecipeService().getRecipes(query, from, to);
  //   // 3: The variable recipeMap uses Dart’s json.decode() to decode the
  //   // string into a map of type Map<String, dynamic>.
  //   final recipeMap = json.decode(recipeJson);
  //   // 4: You use the JSON parsing method you created in the previous
  //   // chapter to create an APIRecipeQuery model.
  //   return APIRecipeQuery.fromJson(recipeMap);
  // }

  // Add loadRecipes
  // 1. Loads recipes1.json from the assets directory. rootBundle is the
  //    top-level property that holds references to all the items in the
  //    asset folder. This loads the file as a string.
  // 2. Uses the built-in jsonDecode() method to convert the string to a map,
  //    then uses fromJson(), which was generated for you, to make an
  //    instance of an APIRecipeQuery.
  // Future loadRecipes() async {
  //   // 1
  //   final jsonString = await rootBundle.loadString('assets/recipes1.json');
  //   setState(() {
  //     // 2
  //     _currentRecipes1 = APIRecipeQuery.fromJson(jsonDecode(jsonString));
  //   });
  // }

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

  // // 1. Checks to see if the list of recipes is null.
  // // 2. If not, calls _buildRecipeCard() using the first item in the list.
  // Widget _buildRecipeLoader(BuildContext context) {
  //   // 1
  //   if (_currentRecipes1 == null || _currentRecipes1?.hits == null) {
  //     return Container();
  //   }
  //   // Show a loading indicator while waiting for the recipes
  //   return Center(
  //     // 2
  //     child: _buildRecipeCard(context, _currentRecipes1!.hits, 0),
  //   );
  // }

  Widget _buildRecipeLoader(BuildContext context) {
    // 1: You check there are at least three characters in the search term.
    // You can change this value, but you probably won’t get good results
    // with only one or two characters.
    if (searchTextController.text.length < 3) {
      return Container();
    }
    // 2: FutureBuilder determines the current state of the Future that
    // APIRecipeQuery returns. It then builds a widget that displays
    // asynchronous data while it’s loading.

    // return FutureBuilder<APIRecipeQuery>(
    return FutureBuilder<Response<Result<APIRecipeQuery>>>(
      // 3: You assign the Future that getRecipeData returns to future.
      // future: getRecipeData(searchTextController.text.trim(),
      //     currentStartPosition, currentEndPosition),
      future: RecipeService.create().queryRecipes(
          searchTextController.text.trim(),
          currentStartPosition,
          currentEndPosition),

      // 4: builder is required; it returns a widget.
      builder: (context, snapshot) {
        // 5: You check the connectionState. If the state is done,
        // you can update the UI with the results or an error.
        if (snapshot.connectionState == ConnectionState.done) {
          // 6: If there’s an error, return a simple Text
          // element that displays the error message.
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString(),
                  textAlign: TextAlign.center, textScaleFactor: 1.3),
            );
          }

          // 7: If there’s no error, process the query results
          // and add query.hits to currentSearchList.
          loading = false;
          // final query = snapshot.data;

          // 1: Check to see if the call was successful.
          if (false == snapshot.data?.isSuccessful) {
            var errorMessage = 'Problems getting data';
            // 2: Check for an error map and extract the message to show.
            if (snapshot.data?.error != null &&
                snapshot.data?.error is LinkedHashMap) {
              final map = snapshot.data?.error as LinkedHashMap;
              errorMessage = map['message'];
            }
            return Center(
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
            );
          }

          // 3: snapshot.data is now a Response and not a string anymore.
          // The body field is either the Success or Error that you defined
          // above. Extract the value of body into result.
          final result = snapshot.data?.body;
          if (result == null || result is Error) {
            // Hit an error:
            // 4: If result is an error, return the current list of recipes.
            inErrorState = true;
            return _buildRecipeList(context, currentSearchList);
          }

          // 5: Since result passed the error check, cast it as Success and
          // extract its value into query.
          final query = (result as Success).value;

          inErrorState = false;
          if (query != null) {
            currentCount = query.count;
            hasMore = query.more;
            currentSearchList.addAll(query.hits);
            // 8: If you aren’t at the end of the data,
            // set currentEndPosition to the current location.
            if (query.to < currentEndPosition) {
              currentEndPosition = query.to;
            }
          }
          // 9: Return _buildRecipeList() using currentSearchList.
          return _buildRecipeList(context, currentSearchList);
        }
        // 10: You check that snapshot.connectionState isn’t done.
        else {
          // 11: If the current count is 0, show a progress indicator.
          if (currentCount == 0) {
            // Show a loading indicator while waiting for the recipes
            return const Center(child: CircularProgressIndicator());
          } else {
            // 12: Otherwise, just show the current list.
            return _buildRecipeList(context, currentSearchList);
          }
        }
      },
    );
  }

  // 1: This method returns a widget and takes recipeListContext and a list of recipe hits.
  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
    // 2: You use MediaQuery to get the device’s screen size.
    // You then set a fixed item height and create two columns of cards
    // whose width is half the device’s width.
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;
    // 3: You return a widget that’s flexible in width and height.
    return Flexible(
      // 4: GridView is similar to ListView, but it allows for some interesting
      // combinations of rows and columns. In this case, you use
      // GridView.builder() because you know the number of items
      // and you’ll use an itemBuilder.
      child: GridView.builder(
        // 5: You use _scrollController, created in initState(), to detect
        // when scrolling gets to about 70% from the bottom.
        controller: _scrollController,
        // 6: The SliverGridDelegateWithFixedCrossAxisCount delegate
        // has two columns and sets the aspect ratio.
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        // 7: The length of your grid items depends on the
        // number of items in the hits list.
        itemCount: hits.length,
        // 8: itemBuilder now uses _buildRecipeCard() to return a card for
        // each recipe. _buildRecipeCard() retrieves the recipe from the hits
        // list by using hits[index].recipe.
        itemBuilder: (BuildContext context, int index) {
          return _buildRecipeCard(recipeListContext, hits, index);
        },
      ),
    );
  }

  // 1. Finds the recipe at the given index.
  // 2. Calls recipeStringCard(), which shows a nice card below the search field.
  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    // 1
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext, MaterialPageRoute(
          builder: (context) {
            return const RecipeDetails();
          },
        ));
      },
      // 2
      child: recipeCard(recipe),
    );
  }
}
