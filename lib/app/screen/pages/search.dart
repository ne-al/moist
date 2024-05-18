import 'package:flutter/material.dart';
import 'package:moist/app/components/textfield/search/search_textfield.dart';
import 'package:moist/app/theme/text_style.dart';
import 'package:moist/app/widgets/searchtile/search_tile.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/api/yt_music/yt_music.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool searching = false;
  bool typing = true;
  Map items = {};
  List<String> hints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Hero(
          tag: 'search',
          child: SearchTextField(
            autoFocus: true,
            controller: _searchController,
            onChanged: (value) => getHints(value),
            onSubmitted: (value) => searchItems(value),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ListTile(
            //   title: Text(S().searchProvider, style: textStyle(context)),
            //   trailing: DropdownButton2(
            //     underline: const SizedBox.shrink(),
            //     value: searchProvider,
            //     items: const [
            //       DropdownMenuItem(
            //           value: SearchProvider.saavn, child: Text("Saavn")),
            //       DropdownMenuItem(
            //           value: SearchProvider.youtube,
            //           child: Text("Youtube Music"))
            //     ],
            //     onChanged: (value) {
            //       if (value != null) {
            //         setState(() {
            //           searchProvider = value;
            //         });
            //         searchItems(_searchController.text);
            //       }
            //     },
            //   ),
            // ),
            Expanded(
              child: _searchController.text.isEmpty
                  ? Container()

                  // ListView(
                  //     children: Hive.box('searchHistory')
                  //         .keys
                  //         .toList()
                  //         .reversed
                  //         .map((key) {
                  //     String value = Hive.box('searchHistory').get(key);
                  //     return ListTile(
                  //       title: Text(value),
                  //       leading: const Icon(Icons.restore),
                  //       trailing: IconButton(
                  //           onPressed: () {
                  //             Hive.box('searchHistory').delete(key);
                  //             setState(() {});
                  //           },
                  //           icon: const Icon(Icons.delete_outline_rounded)),
                  //       onTap: () {
                  //         _searchController.text = value;
                  //         searchItems(value);
                  //       },
                  //     );
                  //   }).toList())
                  : typing
                      ? ListView(
                          children: hints
                              .map(
                                (e) => ListTile(
                                  title: Text(e),
                                  leading:
                                      const Icon(Icons.arrow_outward_rounded),
                                  onTap: () {
                                    _searchController.text = e;
                                    searchSaavn(e);
                                  },
                                ),
                              )
                              .toList(),
                        )
                      : searching
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: items
                                    .map(
                                      (key, val) {
                                        return MapEntry(
                                          key,
                                          (key == 'Episodes' ||
                                                  key == 'Podcasts')
                                              ? const SizedBox()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      key,
                                                      style: textStyle(context)
                                                          .copyWith(
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                    ),
                                                    ...val.map(
                                                      (item) {
                                                        return SearchTile(
                                                          item: item,
                                                        );
                                                      },
                                                    ).toList(),
                                                  ],
                                                ),
                                        );
                                      },
                                    )
                                    .values
                                    .toList(),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  getHints(query) async {
    setState(() {
      typing = true;
    });
    hints = await YtMusicService().getSearchSuggestions(query: query);
    setState(() {});
  }

  searchItems(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      searching = true;
      typing = false;
    });
    await searchSaavn(query);

    setState(() {
      searching = false;
    });
  }

  searchSaavn(String query) async {
    Map<dynamic, dynamic> songSearchResults =
        await SaavnAPI().fetchSongSearchResults(searchQuery: query, count: 5);
    List<Map<dynamic, dynamic>> searchResults =
        await SaavnAPI().fetchSearchResults(query);
    Map<dynamic, dynamic> results = {
      'Songs': songSearchResults['songs'],
      ...searchResults[0],
    };
    Map newResults = {};
    for (String key in sections) {
      if (results[key] != null) {
        newResults[key] = results[key];
      }
    }

    items = newResults;
  }
}

List<String> sections = [
  'Top Result',
  'Songs',
  'Videos',
  'Playlists',
  'Albums',
  'Artists',
  'Featured playlists',
  'Community playlists',
];
