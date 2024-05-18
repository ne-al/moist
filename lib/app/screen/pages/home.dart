import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:moist/app/components/textfield/search/search_textfield.dart';
import 'package:moist/app/screen/view/playlist_view.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/extension.dart';
import 'package:moist/core/helper/format.dart';
import 'package:moist/core/manager/media_manager.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<dynamic, dynamic> data = {};
  List tiles = [];
  List<dynamic> collection = [];
  Logger logger = Logger();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    /**
     [
       "new_trending",
       "charts",
       "new_albums",
       "tag_mixes",
       "top_playlists",
       "radio",
       "city_mod",
       "artist_recos"
     ]
     **/
    setState(() {
      _isLoading = true;
    });

    data = await SaavnAPI().fetchHomePageData();

    Map formatedData = await FormatResponse.formatPromoLists(data);
    Map modules = formatedData['modules'];
    modules.forEach((key, value) {
      tiles.add({
        'title': value['title'],
      });
    });

    collection = data['collections'];

    List newCollection = [];

    for (var element in collection) {
      if (data[element] != null) {
        newCollection.add(element);
      }
    }

    collection.clear();

    collection.addAll(newCollection);

    logger.d(tiles[1]['title']);

    setState(() {
      _isLoading = false;
    });
  }

  String playlistName(String name) {
    String newName = name == "new_trending"
        ? "TRENDING"
        : name == "charts"
            ? "TOP CHARTS"
            : name == "new_albums"
                ? "LATEST ALBUMS"
                : name == "tag_mixes"
                    ? "MIXES"
                    : name == "top_playlists"
                        ? "TOP PLAYLISTS"
                        : name == "radio"
                            ? "RADIOS"
                            : name == "city_mod"
                                ? "POPULAR NEAR YOU"
                                : name == "artist_recos"
                                    ? "ARTIST'S RADIO"
                                    : name;

    return newName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'MOIST',
          style: GoogleFonts.oswald(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.6,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _getData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: !_isLoading
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        const Gap(12),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: SearchTextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            hintText: 'Search',
                            onSubmitted: (value) {
                              _searchFocus.unfocus();
                            },
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: collection.length + 1,
                          separatorBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Text(
                              tiles[index]['title'].toString(),
                              style: GoogleFonts.oswald(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          itemBuilder: (context, parentIndex) {
                            if (parentIndex == 0 ||
                                parentIndex == collection.length + 1) {
                              return Container();
                            }
                            final String collectionName =
                                collection[parentIndex - 1].toString();
                            var homeData = data[collectionName];

                            return SizedBox(
                              height: constraints.maxHeight * 0.24,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: homeData.length,
                                  itemBuilder: (context, childIndex) {
                                    String id =
                                        homeData[childIndex]['id'].toString();
                                    String thumbnailUrl = homeData[childIndex]
                                            ['image']
                                        .toString()
                                        .replaceAll('150x150', '500x500');
                                    String title = homeData[childIndex]['title']
                                        .toString()
                                        .unescape();

                                    String type =
                                        homeData[childIndex]['type'].toString();
                                    return GestureDetector(
                                      onTap: () async {
                                        _searchFocus.unfocus();
                                        if (type == "radio_station") {
                                          var item = homeData[childIndex];
                                          await MediaManager().playRadio(item);
                                        } else {
                                          pushWithNavBar(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PlaylistView(
                                                id: id,
                                                thumbnailUrl: thumbnailUrl,
                                                title: title,
                                                type: type,
                                                list: homeData[childIndex],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          type != "radio_station"
                                              ? Flexible(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: CachedNetworkImage(
                                                      imageUrl: thumbnailUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : Expanded(
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            thumbnailUrl),
                                                    radius: 100,
                                                  ),
                                                ),
                                          const Gap(4),
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.oswald(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
          );
        },
      ),
    );
  }
}
