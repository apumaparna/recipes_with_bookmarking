import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? apiKey = env['API_KEY'];
String? apiId = env['API_ID'];
const String apiUrl = 'https://api.edamam.com/search';

class RecipeService {
  // 1: getData returns a Future (with an upper case “F”) because an API’s
  // returned data type is determined in the future (lower case “f”).
  // async signifies this method is an asynchronous operation.
  Future getData(String url) async {
    // 2: For debugging purposes, you print out the passed-in URL.
    print('Calling url: $url');
    // 3: response doesn’t have a value until await completes.
    // Response and get() are from the HTTP package.
    // get fetches data from the provided url.
    final response = await get(Uri.parse(url));
    // 4: A statusCode of 200 means the request was successful.
    if (response.statusCode == 200) {
      // 5: You return the results embedded in response.body.
      return response.body;
    } else {
      // 6: Otherwise, you have an error — print the statusCode to the console.
      print(response.statusCode);
    }
  }

  // 1: Create a new method, getRecipes(), with the parameters query,
  // from and to. These let you get specific pages from the complete query.
  // from starts at 0 and to is calculated by adding the from index to your
  // page size. You use type Future<dynamic> for this method because you don‘t
  // know which data type it will return or when it will finish. async signals
  // that this method runs asynchronously.
  Future<dynamic> getRecipes(String query, int from, int to) async {
    // 2: Use final to create a non-changing variable. You use await to tell
    // the app to wait until getData returns its result. Look closely at
    // getData() and note that you’re creating the API URL with the variables
    // passed in (plus the IDs previously created in the Edamam dashboard).
    final recipeData = await getData(
        '$apiUrl?app_id=$apiId&app_key=$apiKey&q=$query&from=$from&to=$to');
    // 3: return the data retrieved from the API.
    return recipeData;
  }
}
