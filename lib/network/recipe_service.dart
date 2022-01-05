// This import is not needed in the Chopper version
// import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// This adds the Chopper package and your models.
import 'package:chopper/chopper.dart';
import 'recipe_model.dart';
import 'model_response.dart';
import 'model_converter.dart';

part 'recipe_service.chopper.dart';

String? apiKey = dotenv.env['API_KEY'];
String? apiId = dotenv.env['API_ID'];

// The /search was removed from the URL so that you can call other
// APIs besides /search. For the previous implementation, the /search was needed.
const String apiUrl = 'https://api.edamam.com';

// 1: @ChopperApi() tells the Chopper generator to build a part file.
// This generated file will have the same name as this file, but with
// .chopper added to it. In this case, it will be recipe_service.chopper.dart.
// Such a file will hold the boilerplate code.
@ChopperApi()
// 2: RecipeService is an abstract class because you only need to define the
// method signatures. The generator script will take these definitions and
// generate all the code needed.
abstract class RecipeService extends ChopperService {
  // 3: @Get is an annotation that tells the generator this is a GET request
  // with a path named search, which you previously removed from the apiUrl.
  // There are other HTTP methods you can use, such as @Post, @Put and @Delete,
  // but you won’t use them in this chapter.
  @Get(path: 'search')
  // 4: You define a function that returns a Future of a Response using the
  // previously created APIRecipeQuery. The abstract Result that you created
  // above will hold either a value or an error.
  Future<Response<Result<APIRecipeQuery>>> queryRecipes(
      // 5: queryRecipes() uses the Chopper @Query annotation to accept a query
      // string and from and to integers. This method doesn’t have a body.
      // The generator script will create the body of this function with
      // all the parameters.
      @Query('q') String query,
      @Query('from') int from,
      @Query('to') int to);

  static RecipeService create() {
    // 1: Create a ChopperClient instance.
    final client = ChopperClient(
      // 2: Pass in a base URL using the apiUrl constant.
      baseUrl: apiUrl,
      // 3: Pass in two interceptors. _addQuery() adds your key and ID to the query.
      // HttpLoggingInterceptor is part of Chopper and logs all calls.
      // It’s handy while you’re developing to see traffic between the app and the server.
      interceptors: [_addQuery, HttpLoggingInterceptor()],
      // 4: Set the converter as an instance of ModelConverter.
      converter: ModelConverter(),
      // 5: Use the built-in JsonConverter to decode any errors.
      errorConverter: const JsonConverter(),
      // 6: Define the services created when you run the generator script.
      services: [
        _$RecipeService(),
      ],
    );
    // 7: Return an instance of the generated service.
    return _$RecipeService(client);
  }
}

Request _addQuery(Request req) {
  // 1: Creates a Map, which contains key-value pairs from the existing Request parameters.
  final params = Map<String, dynamic>.from(req.parameters);
  // 2: Adds the app_id and the app_key parameters to the map.
  params['app_id'] = apiId;
  params['app_key'] = apiKey;
  // 3: Returns a new copy of the Request with the parameters contained in the map.
  return req.copyWith(parameters: params);
}

// CODE COMMENTED OUT -- UPGRADED WITH CHOPPER
// class RecipeService {
//   // 1: getData returns a Future (with an upper case “F”) because an API’s
//   // returned data type is determined in the future (lower case “f”).
//   // async signifies this method is an asynchronous operation.
//   Future getData(String url) async {
//     // 2: For debugging purposes, you print out the passed-in URL.
//     print('Calling url: $url');
//     // 3: response doesn’t have a value until await completes.
//     // Response and get() are from the HTTP package.
//     // get fetches data from the provided url.
//     final response = await get(Uri.parse(url));
//     // 4: A statusCode of 200 means the request was successful.
//     if (response.statusCode == 200) {
//       // 5: You return the results embedded in response.body.
//       return response.body;
//     } else {
//       // 6: Otherwise, you have an error — print the statusCode to the console.
//       print(response.statusCode);
//     }
//   }

//   // 1: Create a new method, getRecipes(), with the parameters query,
//   // from and to. These let you get specific pages from the complete query.
//   // from starts at 0 and to is calculated by adding the from index to your
//   // page size. You use type Future<dynamic> for this method because you don‘t
//   // know which data type it will return or when it will finish. async signals
//   // that this method runs asynchronously.
//   Future<dynamic> getRecipes(String query, int from, int to) async {
//     // 2: Use final to create a non-changing variable. You use await to tell
//     // the app to wait until getData returns its result. Look closely at
//     // getData() and note that you’re creating the API URL with the variables
//     // passed in (plus the IDs previously created in the Edamam dashboard).
//     final recipeData = await getData(
//         '$apiUrl?app_id=$apiId&app_key=$apiKey&q=$query&from=$from&to=$to');
//     // 3: return the data retrieved from the API.
//     return recipeData;
//   }
// }
