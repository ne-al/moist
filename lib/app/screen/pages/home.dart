import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:moist/app/components/home_page_tile.dart';
import 'package:moist/app/components/textfield/search/search_textfield.dart';
import 'package:moist/app/screen/pages/search.dart';
import 'package:moist/app/widgets/recently_played.dart';
import 'package:moist/core/api/saavn/api.dart';
import 'package:moist/core/helper/format.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  Map<dynamic, dynamic> homeData = {};
  List songs = [];
  Logger logger = Logger();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    Box homeCache = Hive.box('homeCache');
    songs = await homeCache.get('homeData', defaultValue: []);

    DateTime? time = await homeCache.get('lastUpdated', defaultValue: null);

    int? timeDiff = time?.difference(DateTime.now()).inHours;

    if (timeDiff != null && timeDiff <= 2) {
      logger.e('Skip fetching home data $timeDiff');
      setState(() {});
      return;
    }

    setState(() {
      if (songs.isEmpty) {
        _isLoading = true;
      }
    });

    logger.w('fetching home data');

    songs = await fetchHomeData();

    await Hive.box('homeCache').putAll({
      'homeData': songs,
      'lastUpdated': DateTime.now(),
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<List> fetchHomeData() async {
    List songData = [];
    homeData = await SaavnAPI().fetchHomePageData();
    Map formatedData = await FormatResponse.formatPromoLists(homeData);
    Map modules = formatedData['modules'];
    modules.forEach((key, value) {
      songData.add({
        'title': value['title'],
        'items': formatedData[key],
      });
    });

    return songData;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Hero(
          tag: 'search',
          child: SearchTextField(
            controller: _searchController,
            readOnly: true,
            onTap: () {
              pushScreenWithNavBar(context, const SearchPage());
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _getData(),
        child: !_isLoading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    const Gap(12),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const RecentlyPlayed(),
                        ...songs
                            .map((item) => HomePageTile(sectionIitem: item)),
                      ],
                    ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
