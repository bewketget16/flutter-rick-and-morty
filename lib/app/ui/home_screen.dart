import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty/app/model/character.dart';
import 'package:rick_and_morty/app/utils/query.dart';
import 'package:rick_and_morty/app/widgets/character_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/logo.png",
          height: 62,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search bar and location filter row
              Row(
                children: [
                  // Search bar
                  Expanded(
                    flex: 2, // Adjust the flex value to control the width ratio
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Adjust the gap size here
                  // Location filter
                  Expanded(
                    flex: 1, // Adjust the flex value to control the width ratio
                    child: DropdownButton<String>(
                      isExpanded: true, // Ensure the dropdown takes full width
                      hint: Text('Filter by location'),
                      value: selectedLocation,
                      onChanged: (newValue) {
                        setState(() {
                          selectedLocation = newValue;
                        });
                      },
                      items: <String>[
                        'All Locations',
                        'Earth (C-137)',
                        'Abadango',
                        'Citadel of Ricks',
                        'Post-Apocalyptic Earth',
                        'Anatomy Park',
                        'Interdimensional Cable'
                        // Add more locations as needed
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value == 'All Locations' ? null : value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Query(
                  builder: (result, {fetchMore, refetch}) {
                    if (result.data != null) {
                      int? nextPage = 1;
                      List<Character> characters =
                          (result.data!["characters"]["results"] as List)
                              .map((e) => Character.fromMap(e))
                              .toList();

                      nextPage = result.data!["characters"]["info"]["next"];

                      // Filter characters based on search and location
                      characters = characters.where((character) {
                        final nameMatch = character.name
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase());
                        final locationMatch = selectedLocation == null ||
                            character.location == selectedLocation;
                        return nameMatch && locationMatch;
                      }).toList();

                      return RefreshIndicator(
                        onRefresh: () async {
                          await refetch!();
                          nextPage = 1;
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Center(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: characters
                                      .map((e) => CharacterWidget(character: e))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (nextPage != null)
                                ElevatedButton(
                                    onPressed: () async {
                                      FetchMoreOptions opts = FetchMoreOptions(
                                        variables: {'page': nextPage},
                                        updateQuery: (previousResultData,
                                            fetchMoreResultData) {
                                          final List<dynamic> repos = [
                                            ...previousResultData!["characters"]
                                                ["results"] as List<dynamic>,
                                            ...fetchMoreResultData![
                                                    "characters"]["results"]
                                                as List<dynamic>
                                          ];
                                          fetchMoreResultData["characters"]
                                              ["results"] = repos;
                                          return fetchMoreResultData;
                                        },
                                      );
                                      await fetchMore!(opts);
                                    },
                                    child: result.isLoading
                                        ? const CircularProgressIndicator
                                            .adaptive()
                                        : const Text("Load More")),
                            ],
                          ),
                        ),
                      );
                    } else if (result.data == null) {
                      return const Text("Data Not Found!");
                    } else if (result.isLoading) {
                      return const Center(
                        child: Text("Loading..."),
                      );
                    } else {
                      return const Center(
                        child: Center(child: Text("Something went wrong")),
                      );
                    }
                  },
                  options: QueryOptions(
                    fetchPolicy: FetchPolicy.cacheAndNetwork,
                    document: getAllCharachters(),
                    variables: const {"page": 1},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
